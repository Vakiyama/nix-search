import api/search
import gleam/io
import gleam/list
import tui/model/model

pub fn render(state: model.Model) {
  times(80, newline)
  case state {
    model.Search(search_params) -> render_search(search_params)
    model.Results(results_params) -> render_results(results_params)
  }

  state
}

fn render_search(payload: model.SearchState) {
  io.println("Enter a package name:")
}

fn render_results(payload: model.ResultsState) {
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

pub fn print_package_list(list) {
  list.each(list, fn(item) {
    newline()
    print_package(item)
  })
}

pub fn newline() {
  io.println("")
}

fn print_package(package: search.Package) {
  print_if_check_not_empty("Name: " <> package.name, check: package.name)
  print_if_check_not_empty(
    "Package Name: " <> package.package_name,
    check: package.package_name,
  )
  print_if_check_not_empty(
    "Description: " <> package.description,
    check: package.description,
  )
  print_if_check_not_empty(
    "Version: " <> package.version,
    check: package.version,
  )
}

fn print_if_check_not_empty(message full, check check_mess) {
  case check_mess {
    "" -> Nil
    _ -> io.println(full)
  }
}
