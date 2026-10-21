# Scrape the online dating services comparison table. Run from the project root: Rscript src/scrape_dating.R
library(httr2)
library(rvest)
library(readr)

html <- request("https://en.wikipedia.org/wiki/Comparison_of_online_dating_services") |>
  req_user_agent("wikimill-project/0.1") |>
  req_perform() |>
  resp_body_html()

tables <- html_table(html)
dating <- Filter(\(t) any(grepl("Registered users", names(t))), tables)[[1]]
names(dating) <- c(
  "name", "description", "owner", "registered_users", "free",
  "all_features_free", "hetero", "poly", "free_messaging", "std_notification"
)
write_csv(dating, "data/dating_services.csv")
print(head(dating))
