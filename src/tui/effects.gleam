import app/message
import gleam/javascript/promise

pub type Task(a) {
  Run(
    effect: Effect(a),
    on_ok: fn(a) -> message.Message,
    on_error: fn(String) -> message.Message,
  )
  Message(message.Message)
  Exit
}

pub type Effect(a) =
  fn() -> promise.Promise(a)

pub fn map(over eff: Effect(a), with mapper) -> Effect(b) {
  fn() { promise.map(eff(), mapper) }
}

pub fn try(over eff: Effect(a), with mapper: fn(a) -> Effect(b)) -> Effect(b) {
  fn() { promise.await(eff(), fn(result) { mapper(result)() }) }
}

pub fn none() {
  Message(message.None)
}
