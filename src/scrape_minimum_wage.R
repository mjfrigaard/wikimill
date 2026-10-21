# Scrape the minimum wage table. Run from the project root: Rscript src/scrape_minimum_wage.R
library(httr2)
library(rvest)
library(dplyr)
library(readr)

html <- request("https://en.wikipedia.org/wiki/List_of_countries_by_minimum_wage") |>
  req_user_agent("wikimill-project/0.1") |>
  req_perform() |>
  resp_body_html()

tables <- html_table(html)
wage <- Filter(\(t) "Annual" %in% names(t), tables)[[1]]
# html_table() keeps only the top header row; the second one lands in row 1
names(wage) <- paste(names(wage), unlist(wage[1, ]), sep = "_")
wage <- wage[-1, ] |>
  mutate(across(matches("Nominal|PPP"), parse_number))
write_csv(wage, "data/minimum_wage.csv")
print(head(wage))
