# Scrape the recessions table. Run from the project root: Rscript src/scrape_recessions.R
library(httr2)
library(rvest)
library(readr)

html <- request("https://en.wikipedia.org/wiki/List_of_recessions_in_the_United_States") |>
  req_user_agent("wikimill-project/0.1") |>
  req_perform() |>
  resp_body_html()

tables <- html_table(html)
recessions <- Filter(\(t) any(grepl("GDP decline", names(t))), tables)[[1]]
names(recessions) <- c(
  "name", "period_range", "duration", "time_since_previous",
  "peak_unemployment", "gdp_decline", "characteristics"
)
write_csv(recessions, "data/recessions.csv")
print(head(recessions))
