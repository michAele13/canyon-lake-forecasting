#========================================================================
# MODELING
# Canyon Lake Forecasting Project
#========================================================================

library(tidyverse)
library(fpp3)
library(patchwork)

dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

#========================================================================
# LOAD CLEANED DATA
#========================================================================

canyon_monthly <- read_csv("data/processed/canyon_monthly.csv") %>%
  mutate(month = yearmonth(month)) %>%
  as_tsibble(index = month)

#========================================================================
# TRAIN / TEST SPLIT
#========================================================================

train_data <- canyon_monthly %>%
  filter(month <= yearmonth("2021 Dec"))

test_data <- canyon_monthly %>%
  filter(month > yearmonth("2021 Dec"))

cat("Training observations:", nrow(train_data), "\n")
cat("Test observations:    ", nrow(test_data), "\n")

#========================================================================
# TRANSFORMATION / STATIONARITY CHECKS
#========================================================================

lambda <- train_data %>%
  features(percent_full, features = guerrero) %>%
  pull(lambda_guerrero)

cat("Guerrero lambda:", round(lambda, 3), "\n")

stationarity_checks <- bind_rows(
  train_data %>%
    features(percent_full, unitroot_nsdiffs) %>%
    mutate(check = "seasonal_differencing"),
  
  train_data %>%
    features(difference(percent_full, 12), unitroot_ndiffs) %>%
    mutate(check = "nonseasonal_differencing_after_seasonal")
)

write_csv(stationarity_checks, "outputs/stationarity_checks.csv")

#========================================================================
# MODEL FITTING
#========================================================================

models <- train_data %>%
  model(
    ETS_Auto   = ETS(percent_full),
    ARIMA_Auto = ARIMA(percent_full),
    TSLM       = TSLM(percent_full ~ trend() + season()),
    Ensemble   = (ETS(percent_full) + ARIMA(percent_full) +
                    TSLM(percent_full ~ trend() + season())) / 3
  )

#========================================================================
# FORECASTING
#========================================================================

fc <- forecast(models, h = 36)

#========================================================================
# ACCURACY TABLE
#========================================================================

accuracy_table <- fc %>%
  accuracy(test_data) %>%
  select(.model, RMSE, MAE, MAPE) %>%
  arrange(RMSE)

write_csv(accuracy_table, "outputs/model_accuracy.csv")

#========================================================================
# LJUNG-BOX TEST
#========================================================================

ljung_results <- augment(models) %>%
  filter(.model %in% c("ETS_Auto", "ARIMA_Auto", "TSLM")) %>%
  group_by(.model) %>%
  features(.innov, ljung_box, lag = 24, dof = 0) %>%
  rename(
    Model = .model,
    LB_Statistic = lb_stat,
    p_value = lb_pvalue
  ) %>%
  mutate(
    Residuals_Clean = if_else(p_value > 0.05, "Yes", "No")
  )

write_csv(ljung_results, "outputs/ljung_box_results.csv")

#========================================================================
# SAVE MODEL REPORTS
#========================================================================

capture.output(
  report(models$ETS_Auto[[1]]),
  file = "outputs/ets_model_report.txt"
)

capture.output(
  report(models$ARIMA_Auto[[1]]),
  file = "outputs/arima_model_report.txt"
)

capture.output(
  report(models$TSLM[[1]]),
  file = "outputs/tslm_model_report.txt"
)

#========================================================================
# FORECAST PLOT
#========================================================================

model_colors <- c(
  "ETS_Auto"   = "#2E86AB",
  "ARIMA_Auto" = "#A23B3B",
  "TSLM"       = "#3D7A5C",
  "Ensemble"   = "#7B6FA0"
)

forecast_plot <- fc %>%
  autoplot(canyon_monthly, level = 95, alpha = 0.8) +
  scale_color_manual(values = model_colors) +
  scale_fill_manual(values = model_colors) +
  labs(
    title = "Canyon Lake Storage Forecasts: Four-Model Comparison",
    subtitle = "Forecast period: Jan 2022 – Dec 2024 | 95% prediction intervals",
    caption = "Source: Texas Water Data",
    y = "Percent Full (%)",
    x = NULL,
    color = "Model",
    fill = "Model"
  )

ggsave(
  "figures/forecast_comparison.png",
  plot = forecast_plot,
  width = 10,
  height = 5,
  dpi = 300,
  bg = "white"
)

