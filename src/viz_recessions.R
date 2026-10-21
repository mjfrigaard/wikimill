# Plot recessions. Run from the project root: Rscript src/viz_recessions.R
library(dplyr)
library(readr)
library(ggplot2)
library(forcats)

recessions <- read_csv("data/recessions_clean.csv") |>
  mutate(generation_label = fct_reorder(generation_label, entry_start))

era_colors <- c(
  "Dot-com bust" = "#d62728", "Financial crisis" = "#1f77b4",
  "COVID-19" = "#2ca02c", "Other" = "grey50"
)

# Timeline: one lollipop per recession, shaded by generation entry window
generations <- distinct(recessions, generation, band_start, band_end, band_mid, band_label, shade)

p_timeline <- ggplot(recessions) +
  geom_rect(
    data = generations,
    aes(xmin = band_start, xmax = band_end, ymin = -Inf, ymax = Inf, fill = shade),
    show.legend = FALSE
  ) +
  geom_text(
    data = generations,
    aes(x = band_mid, y = 24.5, label = band_label),
    size = 3, fontface = "bold", lineheight = 0.9
  ) +
  geom_segment(aes(x = start_date, xend = start_date, y = 0, yend = gdp_decline_pct, color = era)) +
  geom_point(aes(x = start_date, y = gdp_decline_pct, color = era), size = 2.5) +
  geom_text(
    aes(x = start_date, y = gdp_decline_pct, label = name),
    angle = 90, hjust = -0.15, size = 2.8
  ) +
  scale_fill_manual(values = c("TRUE" = "grey92", "FALSE" = "grey97")) +
  scale_color_manual(values = era_colors) +
  scale_x_date(date_breaks = "10 years", date_labels = "%Y", expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 26), expand = c(0, 0)) +
  labs(
    x = "Recession start", y = "GDP decline, peak to trough (%)", color = "Era",
    title = "The recessions that shaped each generation's\nentry into the job market",
    subtitle = "Shaded bands mark when each generation turned 22"
  ) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(), legend.position = "bottom")

ggsave("img/fig_recessions_timeline.png", p_timeline, width = 9, height = 5.5)

# Lollipops grouped by generation, row height proportional to recession count
p_generation <- ggplot(recessions, aes(x = gdp_decline_pct, y = fct_reorder(label, gdp_decline_pct), color = era)) +
  geom_segment(aes(x = 0, xend = gdp_decline_pct, yend = fct_reorder(label, gdp_decline_pct))) +
  geom_point(size = 2.5) +
  facet_grid(generation_label ~ ., scales = "free_y", space = "free_y") +
  scale_color_manual(values = era_colors) +
  labs(
    x = "GDP decline, peak to trough (%)", y = NULL, color = "Era",
    title = "The recessions that shaped each generation's\nentry into the job market"
  ) +
  theme_minimal() +
  theme(
    strip.text.y = element_text(face = "bold", angle = 0, hjust = 0),
    panel.grid.major.y = element_blank(),
    panel.spacing.y = unit(1, "lines"),
    legend.position = "bottom"
  )

ggsave("img/fig_recessions_generation.png", p_generation, width = 7, height = 6)
