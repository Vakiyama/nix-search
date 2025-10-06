import api/search
import gleam/option

pub type Model {
  Search(SearchState)
  Results(ResultsState)
}

pub type SearchState {
  SearchState(query: String)
}

pub type ResultsState {
  ResultsState(
    query: String,
    results: option.Option(Result(List(search.Package), search.CommandError)),
  )
}

pub fn init() {
  Search(SearchState(""))
}
