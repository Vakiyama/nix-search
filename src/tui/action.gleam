import ffi/input
import gleam/io
import gleam/result
import tui/tui

pub fn run_action(state: tui.State) {
  case state {
    tui.Search(search_payload) -> run_search_action(search_payload)
    tui.Results(results_payload) -> run_results_action(results_payload)
  }
}

fn run_search_action(payload: tui.SearchState) {
  use input <- result.map(input.input(payload.query))

  io.println(input)

  tui.SearchState(query: payload.query <> input)
  |> tui.Search
}

fn run_results_action(payload: tui.ResultsState) {
  // will be a single char
  use input <- result.map(input.input(payload.query))
  todo
}
