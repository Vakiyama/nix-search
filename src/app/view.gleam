import app/model

// import screens/results/model as results_model
import screens/search/view as search

pub fn view(state: model.Model) {
  case state {
    model.Search(search_params) -> search.view(search_params)
    model.Results(_results_params) -> {
      todo
    }
    model.ErrorScreen(message) -> message
  }
}
