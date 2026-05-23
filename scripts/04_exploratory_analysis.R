#==========================================================================
# EXPLORATORY ANALYSIS
# Canyon Lake Forecasting Project
#==========================================================================

library(tidyverse)
library(fpp3)

dir.create("figures", showWarnings = FALSE)

#==========================================================================
# LOAD CLEANED DATA
#==========================================================================

canyon_monthly <- read_csv("data/processed/canyon_monthly.csv") %>%
  mutate(month = yearmonth(month)) %>%
  as_tsibble(index = month)

train_data <- canyon_monthly %>%
  filter(month <= yearmonth("2021 Dec"))

#==========================================================================
# THEME
#==========================================================================

theme_canyon <- function(accent_color = "#2E86AB") {
  theme_minimal() +
    theme(
      plot.title       = element_text(size = 11, face = "bold", color = "#1a3a2a"),
      plot.subtitle    = element_text(size = 9, color = "#555555"),
      plot.caption     = element_text(size = 8, color = "gray50", hjust = 0),
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "#F7FAFA", color = NA),
      panel.grid.major = element_line(color = "#DDE8E8", linewidth = 0.4),
      panel.grid.minor = element_blank(),
      axis.title       = element_text(size = 9, color = "#333333"),
      axis.text        = element_text(size = 8, color = "#555555"),
      legend.position  = "bottom"
    )
}

theme_set(theme_canyon())

#==========================================================================
# FULL SERIES PLOT
#==========================================================================

full_series_plot <- canyon_monthly %>%
  autoplot(percent_full, linewidth = 1.1) +
  geom_vline(
    xintercept = yearmonth("2022 Jan"),
    linetype = "dashed",
    color = "#7B6FA0",
    linewidth = 0.8
  ) +
  annotate(
    "text",
    x = yearmonth("2018 Jun"),
    y = 85,
    label = "Training",
    color = "#3D7A5C",
    size = 3
  ) +
  annotate(
    "text",
    x = yearmonth("2023 Jun"),
    y = 85,
    label = "Test",
    color = "#A23B3B",
    size = 3
  ) +
  labs(
    title = "Canyon Lake: Percent Full (2010–2024)",
    subtitle = "Dashed line indicates train/test split | Training: Jan 2010–Dec 2021 | Test: Jan 2022–Dec 2024",
    y = "Percent Full (%)",
    x = NULL
  )

ggsave(
  "figures/full_time_series.png",
  plot = full_series_plot,
  width = 10,
  height = 5,
  dpi = 300,
  bg = "white"
)

#==========================================================================
# ACF / PACF PLOT
#==========================================================================

acf_pacf_plot <- train_data %>%
  gg_tsdisplay(percent_full, plot_type = "partial") +
  labs(title = "Canyon Lake: Percent Full — ACF/PACF")

ggsave(
  "figures/acf_pacf_training.png",
  plot = acf_pacf_plot,
  width = 10,
  height = 5,
  dpi = 300,
  bg = "white"
)

#==========================================================================
# STL DECOMPOSITION
#==========================================================================

stl_plot <- train_data %>%
  model(
    STL(percent_full ~ trend(window = 13) + season(window = "periodic"))
  ) %>%
  components() %>%
  autoplot() +
  labs(
    title = "STL Decomposition — Canyon Lake Percent Full",
    subtitle = "Training data: Jan 2010 – Dec 2021",
    caption = "Source: Texas Water Data"
  )

ggsave(
  "figures/stl_decomp_training.png",
  plot = stl_plot,
  width = 10,
  height = 5,
  dpi = 300,
  bg = "white"
)
