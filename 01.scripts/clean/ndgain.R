library(tidyverse)

# Define target countries
target_iso3 <- c("CAN", "DEU", "JPN", "ZAF", "IND",
                 "DNK", "CHL", "COL", "SAU")

# Load ND-GAIN
ndgain_raw <- read_csv("02.data/data-raw/gain.csv") 

# Reshape and Filter
ndgain_clean <- ndgain_raw %>%
  # ND-GAIN uses ISO3 as the ID column usually named 'ISO3' or 'iso3'
  rename_all(tolower) %>%
  filter(iso3 %in% target_iso3) %>%
  # Pivot all year columns (e.g., 1995:2023) into rows
  pivot_longer(
    cols = matches("^[0-9]{4}$"), 
    names_to = "year", 
    values_to = "score"
  ) %>%
  mutate(year = as.numeric(year))

# 3. Quick Status Check
ndgain_clean %>%
  group_by(iso3) %>%
  summarise(latest_score = last(score), .groups = "drop")
