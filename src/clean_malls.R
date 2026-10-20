# Clean the defunct malls table. Run from the project root: Rscript src/clean_malls.R
library(dplyr)
library(readr)
library(forcats)

malls_clean <- read_csv("data/defunct_malls.csv") |>
  mutate(status = factor(status, levels = c("Demolished", "Abandoned", "Defunct"))) |>
  arrange(status) |>
  distinct(title, .keep_all = TRUE)

write_csv(malls_clean, "data/defunct_malls_clean.csv")
print(malls_clean |> count(status, sort = TRUE))
