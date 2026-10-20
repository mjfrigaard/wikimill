# Plot recessions. Run from the project root: Rscript src/viz_recessions.R
library(dplyr)
library(readr)
library(ggplot2)
library(forcats)

recessions <- read_csv("data/recessions_clean.csv")

p <- ggplot(recessions, aes(x = fct_reorder(name, gdp_decline_pct), y = gdp_decline_pct, fill = era)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c(
    "Dot-com bust" = "#d62728", "Financial crisis" = "#1f77b4",
    "COVID-19" = "#2ca02c", "Other" = "grey70"
  )) +
  labs(
    x = NULL, y = "GDP decline, peak to trough (%)", fill = "Era",
    title = "The recessions that shaped millennial entry into the job market"
  ) +
  theme_minimal()

ggsave("data/fig_recessions.png", p, width = 8, height = 6)
