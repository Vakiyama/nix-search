import ffi/execute
import gleam/io
import tui/print
import tui/tui

pub fn render(state: tui.State) {
  times(80, print.newline)
  case state {
    tui.Search(search_params) -> render_search(search_params)
    tui.Results(results_params) -> render_results(results_params)
  }

  state
}

fn render_search(payload: tui.SearchState) {
  io.println("Enter a package name:")
}

fn render_results(payload: tui.ResultsState) {
  todo
  // print.print_package_list(payload.results)
}

fn times(n: Int, function) {
  case n {
    0 -> function()
    count -> {
      function()
      times(count - 1, function)
    }
  }
}
