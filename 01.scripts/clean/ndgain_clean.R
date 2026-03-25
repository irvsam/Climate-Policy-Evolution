
# Reshape and Filter
ndgain_final_clean <- ndgain_raw %>%
  rename_all(tolower) %>%
  filter(iso3 %in% TARGET_ISO3) %>%
  # Pivot all year columns (e.g., 1995:2023) into rows
  pivot_longer(
    # Explaining this regex: ^[0-9]{4}$ matches any column name that consists of exactly 4 digits, which corresponds to year columns like 1995, 1996, ..., 2023. 
    cols = matches("^[0-9]{4}$"), 
    names_to = "year", 
    values_to = "score"
  ) %>%
  mutate(year = as.numeric(year))

message("--- NDGAIN Cleaning Complete ---")