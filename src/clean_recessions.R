# Clean the recessions table. Run from the project root: Rscript src/clean_recessions.R
library(dplyr)
library(readr)
library(stringr)

generation_levels <- c(
  "Greatest Generation", "Silent Generation", "Baby Boomers",
  "Generation X", "Millennials", "Generation Z"
)

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
    ),
    entry_birth_year = start_year - 22L,
    generation = case_when(
      entry_birth_year < 1928 ~ "Greatest Generation",
      entry_birth_year < 1946 ~ "Silent Generation",
      entry_birth_year < 1965 ~ "Baby Boomers",
      entry_birth_year < 1981 ~ "Generation X",
      entry_birth_year < 1997 ~ "Millennials",
      TRUE ~ "Generation Z"
    ),
    generation = factor(generation, levels = generation_levels)
  ) |>
  filter(start_year >= 1945, !is.na(gdp_decline_pct))

write_csv(recessions, "data/recessions_clean.csv")
print(recessions)
