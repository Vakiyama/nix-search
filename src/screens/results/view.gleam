import gleam/list
import lib/search/search

pub fn print_package_list(list) {
  list.fold(over: list, from: "", with: fn(acc, item) {
    acc <> print_package(item)
  })
}

pub fn newline() {
  "\n"
}

fn print_package(package: search.Package) {
  newline()
  <> "Name: "
  <> package.name
  <> newline()
  <> "Package Name: "
  <> package.package_name
  <> newline()
  <> "Description: "
  <> package.description
  <> newline()
  <> "Version: "
  <> package.version
  <> newline()
}
