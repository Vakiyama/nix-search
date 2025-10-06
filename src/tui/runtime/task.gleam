import gleam/javascript/promise

pub type Effect(a) =
  fn() -> promise.Promise(a)
