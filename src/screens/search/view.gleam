import screens/search/model

pub fn view(model: model.SearchModel) {
  "Enter a package name: " <> model.query <> "█"
}
