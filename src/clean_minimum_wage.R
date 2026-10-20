# Clean the minimum wage table. Run from the project root: Rscript src/clean_minimum_wage.R
library(dplyr)
library(readr)

wage_clean <- read_csv("data/minimum_wage.csv") |>
  select(matches("Country"), matches("Annual_Nominal")) |>
  rename(country = 1, annual_wage_usd = 2) |>
  mutate(annual_wage_usd = as.double(annual_wage_usd)) |>
  filter(!is.na(annual_wage_usd))

write_csv(wage_clean, "data/minimum_wage_clean.csv")
print(wage_clean)
