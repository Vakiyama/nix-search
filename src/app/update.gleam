import app/message
import app/model
import gleam/result
import lib/input/input

import screens/search/message as search_message
import screens/search/update as search_update

import tui/effects

pub fn update(
  model: model.Model,
  message: message.Message,
) -> #(model.Model, effects.Task(a)) {
  case message {
    message.None -> {
      get_input(model)
    }
    message.Search(search_message) -> {
      search_update.update(model, search_message)
    }
  }
}

fn get_input(model) {
  result.map(input.get_user_input_key(), fn(input_key) {
    #(
      model,
      input_key |> search_message.Input |> message.Search |> effects.Message,
    )
  })
  |> result.unwrap(#(model.ErrorScreen("Program exited..."), effects.Exit))
}
