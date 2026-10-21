# Plot dating services by registered users. Run from the project root: Rscript src/viz_dating.R
library(dplyr)
library(readr)
library(ggplot2)
library(forcats)
library(scales)

dating_top15 <- read_csv("data/dating_services_clean.csv") |>
  mutate(all_features_free_clean = coalesce(all_features_free_clean, "Unknown")) |>
  slice_max(registered_users_n, n = 15)

p <- ggplot(dating_top15, aes(
  x = fct_reorder(name, registered_users_n),
  y = registered_users_n,
  fill = all_features_free_clean
)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale())) +
  scale_fill_manual(values = c(
    "Yes" = "#8dc63f", "No" = "#c62828", "Maybe" = "#f2a71b", "Unknown" = "grey70"
  )) +
  labs(
    x = NULL, y = "Registered users", fill = "All features free?",
    title = "Online dating services by registered users"
  ) +
  theme_minimal()

ggsave("img/fig_dating.png", p, width = 8, height = 6)
