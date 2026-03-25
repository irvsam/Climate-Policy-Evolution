
message("--- Processing OECD CAPMF Data ---")

# Renaming and Filtering ----------------------------------------------
oecd_processed <- oecd_raw %>%
  select(
    iso3 = REF_AREA,
    year = TIME_PERIOD,
    metric_code = CLIM_ACT_POL,
    measure_type = MEASURE,
    value = OBS_VALUE,
    status = OBS_STATUS
  ) %>%
  # Use the global target list defined in main.R
  filter(iso3 %in% TARGET_ISO3)

# Hierarchy and Sector Extraction -------------------------------------------
oecd_processed <- oecd_processed %>%
  mutate(
    Level = str_extract(metric_code, "LEV[1-4]"),
    
    Sector = case_when(
      str_detect(metric_code, "LEV[12]_SEC") & !str_detect(metric_code, "_[ETIB]") ~ "Sectoral (All)",
      str_detect(metric_code, "LEV[12]_CROSS_SEC") ~ "Cross-Sectoral",
      str_detect(metric_code, "LEV[12]_INT") ~ "International",
      str_detect(metric_code, "_E(_|$)") ~ "Energy",
      str_detect(metric_code, "_T(_|$)") ~ "Transport",
      str_detect(metric_code, "_I(_|$)") ~ "Industry",
      str_detect(metric_code, "_B(_|$)") ~ "Buildings",
      TRUE ~ "General/Governance"
    )
  )

# Pivot to wide format (Count vs Stringency) --------------------------------
oecd_wide <- oecd_processed %>%
  pivot_wider(
    names_from = measure_type, 
    values_from = value
  ) %>%
  # Use rename_with to handle cases where one might be missing
  rename(
    count = any_of("POL_COUNT"),
    stringency = any_of("POL_STRINGENCY")
  )

# Fetch Official Metadata Labels from DSD--------------------------------------------
message("Fetching OECD Metadata (DSD)...")


policy_labels <- tryCatch({
  dsd <- get_data_structure("OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0")
  dsd$CL_ACT_POL_CAPMF %>%
    select(metric_code = id, official_label = label)
}, error = function(e) {
  message("Warning: Could not fetch OECD DSD. Using metric codes as names.")
  return(data.frame(metric_code = unique(oecd_wide$metric_code), official_label = NA))
})

# Final Formatting and Labeling ---------------------------------------------
oecd_final_clean <- oecd_wide %>%
  left_join(policy_labels, by = "metric_code") %>%
  mutate(
    # Clean up names
    Policy_Name = coalesce(official_label, metric_code),
    Policy_Name = str_replace_all(Policy_Name, "_", " "),
    Policy_Name = str_to_title(Policy_Name),
    Policy_Name = str_replace_all(Policy_Name, "Nox", "NOx"),
    
    # Refine Description Category
    Policy_Description = case_when(
      str_detect(metric_code, "MBI") ~ "Market-Based Instrument",
      str_detect(metric_code, "NMBI") ~ "Non-Market Regulation",
      str_detect(metric_code, "EMIS_STD") ~ "Regulatory Emission Limit",
      str_detect(metric_code, "CARBONTAX|ETS") ~ "Carbon Pricing",
      str_detect(metric_code, "NZ") ~ "Climate Target",
      TRUE ~ "General Climate Policy"
    )
  ) %>%
  select(
    iso3, year, metric_code, status, Level, Sector, 
    Policy_Name, Policy_Description, stringency, count
  )


message("--- OECD Cleaning Complete ---")