import ffi/input
import tui/model/model

pub type Message {
  Input(input.Key)
}

pub fn update(state: model.Model, message: Message) {
  todo
}
