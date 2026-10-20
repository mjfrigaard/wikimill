# Clean the recessions table. Run from the project root: Rscript src/clean_recessions.R
library(dplyr)
library(readr)
library(stringr)

recessions <- read_csv("data/recessions.csv") |>
  mutate(
    start_year = as.integer(str_extract(period_range, "\\d{4}")),
    gdp_decline_pct = as.numeric(str_extract(gdp_decline, "[\\d.]+")),
    peak_unemployment_pct = as.numeric(str_extract(peak_unemployment, "[\\d.]+")),
    era = case_when(
      start_year %in% 2001 ~ "Dot-com bust",
      start_year %in% 2007:2009 ~ "Financial crisis",
      start_year %in% 2020 ~ "COVID-19",
      TRUE ~ "Other"
    )
  ) |>
  filter(start_year >= 1945, !is.na(gdp_decline_pct))

write_csv(recessions, "data/recessions_clean.csv")
print(recessions)
