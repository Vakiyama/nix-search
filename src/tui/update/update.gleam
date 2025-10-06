import ffi/input
import gleam/option
import gleam/result
import tui/model/model

pub fn update(state: model.Model, message: Message) -> model.Model {
  let update_result = case message {
    None -> get_input(state)
    Input(key) -> handle_input(state, key)
    LoadResults -> {
      todo
    }
    Exit -> Ok(state)
  }

  update_result
  |> result.unwrap(model.Error("Some error occurred"))
}

fn get_input(state) {
  input.get_user_input_key("")
  |> result.map(fn(key) { update(state, Input(key)) })
}

fn handle_input(state, input) {
  case state {
    model.Search(search_model) -> Ok(handle_search_input(search_model, input))
    model.Results(results_model) -> {
      todo
    }
    model.Error(message) -> {
      todo
    }
  }
}

fn handle_search_input(search_model: model.SearchModel, key) {
  case key {
    input.Char(char) -> {
      model.make_search_model(search_model.query <> char)
      |> update(None)
    }
    input.Esc -> {
      model.make_search_model("")
      |> update(Exit)
    }
    input.Enter -> {
      model.make_search_model(search_model.query)
      |> update(LoadResults)
    }
    _ -> update(model.Search(search_model), None)
  }
}
