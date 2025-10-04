import api/search
import gleam/io
import gleam/list

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
