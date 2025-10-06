import tui/message
import tui/model/model
import tui/runtime/effects

@external(javascript, "./ffi/tui_runtime_ffi.mjs", "runtime")
pub fn start(
  init: fn() -> model.Model,
  update: fn(model.Model, message.Message) -> #(model.Model, effects.Effect),
  view: String,
) -> Nil
