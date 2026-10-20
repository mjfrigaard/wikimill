# Clean the dating services table. Run from the project root: Rscript src/clean_dating.R
library(dplyr)
library(readr)
library(stringr)

dating_clean <- read_csv("data/dating_services.csv") |>
  mutate(
    users_raw = str_extract(registered_users, "\\d{1,3}(?:,\\d{3})+"),
    registered_users_n = as.numeric(str_remove_all(users_raw, ",")),
    users_year = as.integer(str_extract(str_remove(registered_users, fixed(users_raw)), "\\d{4}")),
    free_clean = str_extract(free, regex("^(Yes|No|Maybe)", ignore_case = TRUE)),
    all_features_free_clean = str_extract(all_features_free, regex("^(Yes|No|Maybe)", ignore_case = TRUE))
  ) |>
  select(-users_raw) |>
  filter(!is.na(registered_users_n)) |>
  distinct(name, .keep_all = TRUE)

write_csv(dating_clean, "data/dating_services_clean.csv")
print(dating_clean |> select(name, registered_users_n, users_year, free_clean, all_features_free_clean))
