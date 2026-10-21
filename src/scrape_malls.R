# Scrape the defunct malls category. Run from the project root: Rscript src/scrape_malls.R
library(httr2)
library(dplyr)
library(readr)

fetch_category_members <- function(category) {
  resps <- request("https://en.wikipedia.org/w/api.php") |>
    req_user_agent("wikimill-project/0.1") |>
    req_url_query(
      action = "query", list = "categorymembers",
      cmtitle = paste0("Category:", category), cmlimit = 500,
      format = "json"
    ) |>
    req_perform_iterative(
      next_req = iterate_with_cursor(
        "cmcontinue",
        resp_param_value = \(resp) resp_body_json(resp)$continue$cmcontinue
      ),
      max_reqs = Inf
    )
  titles <- resps_data(resps, \(resp) {
    vapply(resp_body_json(resp)$query$categorymembers, \(m) m$title, character(1))
  })
  tibble(title = titles)
}

categories <- c(
  "Defunct_shopping_malls_in_the_United_States" = "Defunct",
  "Demolished_shopping_malls_in_the_United_States" = "Demolished",
  "Abandoned_shopping_malls_in_the_United_States" = "Abandoned"
)
malls <- bind_rows(lapply(names(categories), \(cat) {
  fetch_category_members(cat) |> mutate(status = categories[[cat]])
}))
write_csv(malls, "data/defunct_malls.csv")
print(head(malls))
