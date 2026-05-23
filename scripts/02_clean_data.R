library(tidyverse)
library(fpp3)

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

canyon_raw <- read.csv(
  "data/raw/canyon_lake_raw.csv",
  skip = 54,
  header = TRUE,
  comment.char = ""
)

canyon_monthly <- canyon_raw %>%
  mutate(
    date = as.Date(date),
    month = yearmonth(date)
  ) %>%
  filter(
    month >= yearmonth("2010 Jan"),
    month <= yearmonth("2024 Dec")
  ) %>%
  group_by(month) %>%
  summarise(
    percent_full = mean(percent_full, na.rm = TRUE),
    conservation_storage = mean(conservation_storage, na.rm = TRUE)
  ) %>%
  as_tsibble(index = month)

write_csv(
  canyon_monthly,
  "data/processed/canyon_monthly.csv"
)
