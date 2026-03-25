
# Reshape and Filter
ndgain_final_clean <- ndgain_raw %>%
  # ND-GAIN uses ISO3 as the ID column usually named 'ISO3' or 'iso3'
  rename_all(tolower) %>%
  filter(iso3 %in% TARGET_ISO3) %>%
  # Pivot all year columns (e.g., 1995:2023) into rows
  pivot_longer(
    cols = matches("^[0-9]{4}$"), 
    names_to = "year", 
    values_to = "score"
  ) %>%
  mutate(year = as.numeric(year))

message("--- NDGAIN Cleaning Complete ---")