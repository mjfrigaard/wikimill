# Clean the recessions table. Run from the project root: Rscript src/clean_recessions.R
library(dplyr)
library(readr)
library(stringr)

generations <- tibble(
  generation = c(
    "Greatest Generation", "Silent Generation", "Baby Boomers",
    "Generation X", "Millennials", "Generation Z"
  ),
  birth_start = c(1901L, 1928L, 1946L, 1965L, 1981L, 1997L),
  birth_end = c(1927L, 1945L, 1964L, 1980L, 1996L, 2012L)
) |>
  mutate(
    entry_start = birth_start + 22L,
    entry_end = birth_end + 22L,
    generation_label = paste0(generation, "\nentered ", entry_start, "–", entry_end),
    band_label = sub(" ", "\n", generation),
    band_start = as.Date(paste0(pmax(entry_start, 1944L), "-01-01")),
    band_end = as.Date(paste0(pmin(entry_end, 2025L) + 1L, "-01-01")),
    band_mid = band_start + (band_end - band_start) / 2,
    shade = row_number() %% 2 == 0,
    generation = factor(generation, levels = generation),
    generation_label = factor(generation_label, levels = generation_label)
  )

recessions <- read_csv("data/recessions.csv") |>
  mutate(
    period_range = str_remove_all(period_range, "\\[\\d+\\]"),
    start_date = as.Date(paste("1", str_extract(period_range, "^[A-Za-z]+ \\d{4}")), "%d %B %Y"),
    end_date = as.Date(paste("1", str_extract(period_range, "[A-Za-z]+ \\d{4}$")), "%d %B %Y"),
    start_year = as.integer(format(start_date, "%Y")),
    end_year = as.integer(format(end_date, "%Y")),
    name = case_when(
      start_year == 1945 ~ "Demobilization",
      start_year == 1948 ~ "Tightening",
      start_year == 1953 ~ "Korea",
      start_year == 1957 ~ "Eisenhower",
      start_year == 1960 ~ "Rates",
      start_year == 1969 ~ "Vietnam",
      start_year == 1973 ~ "Oil",
      start_year == 1980 ~ "Volcker",
      start_year == 1981 ~ "Iran",
      start_year == 1990 ~ "Gulf",
      start_year == 2001 ~ "Dotcom",
      start_year == 2007 ~ "Subprime",
      start_year == 2020 ~ "Pandemic",
      TRUE ~ name
    ),
    gdp_decline_pct = as.numeric(str_extract(gdp_decline, "[\\d.]+")),
    peak_unemployment_pct = as.numeric(str_extract(peak_unemployment, "[\\d.]+")),
    era = case_when(
      start_year %in% 2001 ~ "Dot-com bust",
      start_year %in% 2007:2009 ~ "Financial crisis",
      start_year %in% 2020 ~ "COVID-19",
      TRUE ~ "Other"
    ),
    label = if_else(
      start_year == end_year,
      paste0(name, " (", start_year, ")"),
      paste0(name, " (", start_year, "–", end_year, ")")
    )
  ) |>
  filter(start_year >= 1945, !is.na(gdp_decline_pct)) |>
  inner_join(generations, by = join_by(overlaps(start_year, end_year, entry_start, entry_end)))

write_csv(recessions, "data/recessions_clean.csv")
print(recessions)
