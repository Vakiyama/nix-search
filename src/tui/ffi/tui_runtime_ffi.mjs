import * as $message from "../../app/message.mjs";
import * as $effects from "../effects.mjs"

export function run(init, update, view) {
  let exitProgram = false;
  let [model, msg] = init()
  let queue = [];

  function dispatch(msg) {
    if (exitProgram) return;
    queue.push(msg);
    if (queue.length === 1) pump();
  };


  render(model, view);

  interpret(msg, dispatch);

  function exit() {
    exitProgram = true
    queue = [];
  }

  function pump() {
    queueMicrotask(() => {
      while (queue.length) {

        const msg = queue.shift();
        let e;
        [model, e] = update(model, msg);
        render(model, view);
        interpret(e, dispatch, exit);
      }
    });
  }
}

function render(model, view) {
  process.stdout.write("\x1Bc");
  process.stdout.write(view(model) + "\n");
}

async function interpret(eff, dispatch, exit) {
  if (eff instanceof $effects.Run) {
    const { effect, on_ok, on_error } = eff;

    effect()
      .then((value) => {
        dispatch(on_ok(value));
      })
      .catch((err) => {
        dispatch(on_error(err));
      });
  } else if (eff instanceof $effects.Message) {
    dispatch(eff[0])
  } else if (eff instanceof $effects.Exit) {
    exit()
  }
}
