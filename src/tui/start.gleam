import app/message
import app/model
import tui/effects

@external(javascript, "./ffi/tui_runtime_ffi.mjs", "run")
pub fn run(
  init: fn() -> #(model.Model, effects.Task(a)),
  update: fn(model.Model, message.Message) -> #(model.Model, effects.Task(a)),
  view: fn(model.Model) -> String,
) -> Nil
