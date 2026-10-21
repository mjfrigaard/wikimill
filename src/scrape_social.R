# Scrape the most popular social platforms table. Run from the project root: Rscript src/scrape_social.R
library(httr2)
library(rvest)
library(readr)

html <- request("https://en.wikipedia.org/wiki/List_of_most_popular_social_platforms") |>
  req_user_agent("wikimill-project/0.1") |>
  req_perform() |>
  resp_body_html()

tables <- html_table(html)
social <- Filter(\(t) "Country[b]" %in% names(t) && !"No." %in% names(t), tables)[[1]]
names(social) <- c("name", "company", "country", "launched", "monthly_active_users", "other_metrics")
write_csv(social, "data/social_platforms.csv")
print(head(social))
