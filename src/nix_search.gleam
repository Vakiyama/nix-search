import argv
import ffi/execute
import gleam/dict
import gleam/dynamic/decode
import gleam/io
import gleam/list
import gleam/result

pub type Package {
  Package(
    name: String,
    description: String,
    package_name: String,
    version: String,
  )
}

pub type CommandError {
  DecodeError(List(decode.DecodeError))
  ExecuteError(execute.ExecuteError)
}

pub fn main() {
  let assert [package_name] = argv.load().arguments
  // handle input error with message instead

  execute.execute(
    "nix search nixpkgs " <> package_name <> " --json",
    1024 * 1024 * 100,
  )
  |> result.map_error(ExecuteError)
  |> result.try(fn(data) {
    decode.run(data, decode.dict(decode.string, decode.dynamic))
    |> result.map_error(DecodeError)
  })
  |> result.try(turn_package_dict_to_list)
  |> result.map(fn(package_list) {
    list.each(package_list, fn(item) {
      print_newline()
      print_package(item)
    })
  })
}

fn print_newline() {
  io.println("")
}

fn print_package(package: Package) {
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

fn turn_package_dict_to_list(dict) {
  dict.fold(over: dict, from: Ok([]), with: fn(acc, key, value) {
    decode_dynamic_into_package(key, value)
    |> result.map_error(DecodeError)
    |> result.try(fn(package) { result.map(acc, fn(acc) { [package, ..acc] }) })
  })
}

fn decode_dynamic_into_package(name, data) {
  let decoder = {
    use description <- decode.field("description", decode.string)
    use package_name <- decode.field("pname", decode.string)
    use version <- decode.field("version", decode.string)
    decode.success(Package(name:, description:, package_name:, version:))
  }

  decode.run(data, decoder)
}
