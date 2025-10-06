import gleam/option
import lib/search/search

pub type ResultsModel {
  ResultsModel(
    query: String,
    results: option.Option(Result(List(search.Package), search.CommandError)),
  )
}
