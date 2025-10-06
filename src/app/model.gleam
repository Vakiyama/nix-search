import screens/results/model as results_screen
import screens/search/model as search_screen

pub type Model {
  Search(search_screen.SearchModel)
  Results(results_screen.ResultsModel)
  ErrorScreen(message: String)
}
