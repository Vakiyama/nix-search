import api/search
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn search_and_parse_packages_test() {
  let search_result = search.search("ripgrep")
  search_result
  |> should.be_ok

  case search_result {
    Ok(items) -> {
      list.length(items)
      |> should.not_equal(0)
    }
    Error(_err) -> {
      should.fail()
    }
  }
}
