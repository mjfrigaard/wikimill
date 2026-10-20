# Plot minimum wage. Run from the project root: Rscript src/viz_minimum_wage.R
library(dplyr)
library(readr)
library(ggplot2)
library(forcats)
library(scales)

wage_top20 <- read_csv("data/minimum_wage_clean.csv") |>
  slice_max(annual_wage_usd, n = 20)

p <- ggplot(wage_top20, aes(x = fct_reorder(country, annual_wage_usd), y = annual_wage_usd)) +
  geom_col(fill = "#4c72b0") +
  coord_flip() +
  scale_y_continuous(labels = scales::dollar) +
  labs(
    x = NULL, y = "Annual minimum wage (nominal USD)",
    title = "Top 20 countries by minimum wage"
  ) +
  theme_minimal()

ggsave("data/fig_minimum_wage.png", p, width = 8, height = 6)
