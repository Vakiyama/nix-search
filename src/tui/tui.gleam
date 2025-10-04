import api/search
import gleam/option

// some concept of a screen

pub type State {
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

pub fn to_results(state: SearchState) {
  ResultsState(query: state.query, results: option.None)
}

pub fn get_packages(state: ResultsState) {
  ResultsState(
    query: state.query,
    results: option.Some(search.search(state.query)),
  )
}

pub fn to_search(state: ResultsState) {
  Search(SearchState(state.query))
}

pub fn init() {
  Search(SearchState(""))
}
