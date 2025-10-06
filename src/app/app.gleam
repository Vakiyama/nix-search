import app/model
import app/update
import app/view
import tui/effects
import tui/start

import screens/search/model as search

pub fn start() {
  start.run(init, update.update, view.view)
}

fn init() {
  #(
    search.make_search_model("")
      |> model.Search,
    effects.none(),
  )
}
