library(readr)

# Create folders if needed
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

# Download Canyon Lake CSV from Water Data for Texas
download.file(
  url = "https://www.waterdatafortexas.org/reservoirs/individual/canyon.csv",
  destfile = "data/raw/canyon_lake_raw.csv",
  mode = "wb"
)
