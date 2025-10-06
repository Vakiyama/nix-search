import api/search
import gleam/option

pub type Model {
  Search(SearchModel)
  Results(ResultsModel)
  Error(message: String)
}

pub type SearchModel {
  SearchModel(query: String)
}

pub type ResultsModel {
  ResultsModel(
    query: String,
    results: option.Option(Result(List(search.Package), search.CommandError)),
  )
}

pub fn init() {
  Search(SearchModel(""))
}

pub fn make_search_model(query: String) {
  Search(SearchModel(query))
}
