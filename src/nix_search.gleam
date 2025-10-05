import ffi/input
import gleam/io
import tui/action
import tui/print
import tui/render
import tui/tui

pub fn main() {
  loop(tui.init())
}

fn loop(state: tui.State) {
  let action_result =
    state
    // |> render.render
    |> action.run_action

  case action_result {
    Ok(new_state) -> loop(new_state)
    Error(e) ->
      case e {
        input.InputError -> {
          print.newline()
          io.println("Exit...")
        }
      }
  }
}
