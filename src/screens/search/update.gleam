import app/model
import gleam/string
import lib/input/input
import screens/search/message as search_message
import screens/search/model as search_model
import tui/effects

pub fn update(
  model: model.Model,
  message: search_message.SearchMessage,
) -> #(model.Model, effects.Task(a)) {
  case model {
    model.Search(search_model) -> {
      case message {
        search_message.Input(key) -> handle_search_input(search_model, key)
      }
    }
    _ -> #(model, effects.none())
  }
}

fn handle_search_input(search_model: search_model.SearchModel, key) {
  let new_query = case key {
    input.Char(char) -> search_model.query <> char

    // spaces in package name?
    input.Space -> search_model.query <> " "

    input.Esc -> ""

    input.Enter -> todo

    input.Backspace ->
      search_model.query
      |> string.drop_end(1)

    _ -> search_model.query
  }

  #(new_query |> search_model.make_search_model |> model.Search, effects.none())
}
