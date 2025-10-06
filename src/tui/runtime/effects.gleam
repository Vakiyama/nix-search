import gleam/javascript/promise
import tui/message

pub type Task(a) {
  None
  Effect(
    effect: Effect(a),
    ok_tag: fn(a) -> message.Message,
    err_tag: fn(String) -> message.Message,
    id: String,
  )
}

pub type Effect(a) =
  fn() -> promise.Promise(a)

pub fn map(over eff: Effect(a), with mapper) -> Effect(b) {
  fn() { promise.map(eff(), mapper) }
}

pub fn try(over eff: Effect(a), with mapper: fn(a) -> Effect(b)) -> Effect(b) {
  fn() { promise.await(eff(), fn(result) { mapper(result)() }) }
}
