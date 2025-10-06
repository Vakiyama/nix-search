pub type SearchModel {
  SearchModel(query: String)
}

pub fn make_search_model(query: String) {
  SearchModel(query)
}
