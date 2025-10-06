const inflight = new Map();   
const debouncers = new Map(); 

export function run(init, update, view) {
  let [model, eff] = init();
  const queue = [];
  const dispatch = (msg) => {
    queue.push(msg);
    if (queue.length === 1) pump();
  };

  render(model, view);
  interpret(eff, dispatch);

  function pump() {
    queueMicrotask(async () => {
      while (queue.length) {
        const msg = queue.shift();
        let e;
        [model, e] = update(model, msg);
        render(model, view);
        await interpret(e, dispatch);
      }
    });
  }
}

function render(model, view) {
  process.stdout.write("\x1Bc");
  process.stdout.write(view(model) + "\n");
}

async function interpret(eff, dispatch) {
  if (!eff || eff.type === "None") return;
  if (eff.type === "Run") {
    const { task, ok_tag, err_tag, id } = eff;
    const ctrl = ensureController(id);
    runTask(task, ctrl)
      .then((value) => {
        if (ctrl.aborted) return;
        // If value is object, we’ll JSON.stringify it; up to you.
        const body = typeof value === "string" ? value : JSON.stringify(value);
        dispatch({ type: ok_tag, body });
      })
      .catch((err) => {
        if (ctrl.aborted) return;
        dispatch({ type: err_tag, reason: String(err?.message ?? err) });
      });
  }
}

// Controller for cancel/debounce/timeout bookkeeping
function ensureController(id) {
  if (!inflight.has(id)) inflight.set(id, { aborted: false, timers: new Set() });
  return inflight.get(id);
}

function addTimer(ctrl, t) {
  ctrl.timers.add(t);
  const clear = () => ctrl.timers.delete(t);
  return [t, clear];
}

function abort(ctrl, reason) {
  ctrl.aborted = true;
  for (const t of ctrl.timers) clearTimeout(t);
  ctrl.timers.clear();
}

// Execute a Task: run its steps in order
async function runTask(task, ctrl, initialValue = undefined) {
  let current = initialValue;
  for (const step of task.steps ?? []) {
    if (ctrl.aborted) throw new Error("aborted");

    switch (step.type) {
      case "FetchText": {
        const res = await fetch(step.url);
        current = await res.text();
        break;
      }
      case "Debounce": {
        await new Promise((resolve) => {
          const existing = debouncers.get(step.key);
          if (existing) clearTimeout(existing);
          const [t] = addTimer(ctrl, setTimeout(() => {
            debouncers.delete(step.key);
            resolve();
          }, step.ms));
          debouncers.set(step.key, t);
        });
        break;
      }
      default:
        throw new Error(`Unknown step ${step.type}`);
    }
  }
  return current;
}
