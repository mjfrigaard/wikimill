# Clean the social platforms table. Run from the project root: Rscript src/clean_social.R
library(dplyr)
library(readr)
library(stringr)

social_clean <- read_csv("data/social_platforms.csv") |>
  mutate(
    mau_value = as.numeric(str_extract(monthly_active_users, "[\\d.]+")),
    mau_unit = str_extract(monthly_active_users, "billion|million"),
    mau_millions = case_when(
      mau_unit == "billion" ~ mau_value * 1000,
      mau_unit == "million" ~ mau_value,
      TRUE ~ NA_real_
    ),
    company_group = if_else(
      company %in% c("Meta Platforms", "Tencent", "ByteDance", "Microsoft", "Alphabet Inc."),
      company, "Other"
    )
  ) |>
  select(-mau_value, -mau_unit) |>
  filter(!is.na(mau_millions))

write_csv(social_clean, "data/social_platforms_clean.csv")
print(social_clean |> select(name, company, mau_millions, launched))
