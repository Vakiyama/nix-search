import ffi/input

pub type Message {
  Input(input.Key)
  Exit
  None
}
