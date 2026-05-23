#========================================================================
# COLOR PALETTE
#========================================================================
# Canyon Lake color palette — water/canyon theme
model_colors <- c(
  "ETS_Auto"   = "#2E86AB",   # steel blue
  "ARIMA_Auto" = "#A23B3B",   # clay red  ← selected model gets warmest color
  "TSLM"       = "#3D7A5C",   # canyon green
  "Ensemble"   = "#7B6FA0"    # muted purple
)

model_labels <- c(
  "ETS_Auto"   = "ETS (Automatic)",
  "ARIMA_Auto" = "ARIMA (Automatic)",
  "TSLM"       = "TSLM (Linear Regression)"
)

# Theme
theme_canyon <- function(accent_color = "#2E86AB") {
  theme_minimal() +
    theme(
      plot.title       = element_text(size = 11, face = "bold",
                                      color = "#1a3a2a"),
      plot.subtitle    = element_text(size = 9,  color = "#555555"),
      plot.caption     = element_text(size = 8,  color = "gray50", hjust = 0),
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "#F7FAFA", color = NA),
      panel.grid.major = element_line(color = "#DDE8E8", linewidth = 0.4),
      panel.grid.minor = element_blank(),
      axis.title       = element_text(size = 9,  color = "#333333"),
      axis.text        = element_text(size = 8,  color = "#555555"),
      strip.text       = element_text(face = "bold", color = "white"),
      strip.background = element_rect(fill = accent_color),
      legend.position  = "bottom",
      legend.text      = element_text(size = 8),
      legend.title     = element_text(size = 8)
    )
}

theme_set(theme_canyon())