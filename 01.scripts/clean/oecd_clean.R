library(dplyr)
library(stringr)

# ================= Renaming the columns ===========================
oecd_renamed <- oecd_df_granular %>%
  select(
    iso3 = REF_AREA,
    year = TIME_PERIOD,
    metric_code = CLIM_ACT_POL,
    measure_type = MEASURE,
    value = OBS_VALUE,
    status = OBS_STATUS
  )

# ======================== Cleaning the metric_code column =========================
# The CLIM_ACT_POL column contains multiple levels of information

oecd_cleaned <- oecd_renamed %>%
  mutate(
    Level = str_extract(metric_code, "LEV[1-4]"),
   
    Sector = case_when(
      # Level 1 & 2 Aggregates
      str_detect(metric_code, "LEV[12]_SEC") & !str_detect(metric_code, "_[ETIB]") ~ "Sectoral (All)",
      str_detect(metric_code, "LEV[12]_CROSS_SEC") ~ "Cross-Sectoral",
      str_detect(metric_code, "LEV[12]_INT") ~ "International",
      
      # Level 3 & 4 Specific Sectors (using the previous logic)
      str_detect(metric_code, "_E(_|$)") ~ "Energy",
      str_detect(metric_code, "_T(_|$)") ~ "Transport",
      str_detect(metric_code, "_I(_|$)") ~ "Industry",
      str_detect(metric_code, "_B(_|$)") ~ "Buildings",
      
      # Fallback
      TRUE ~ "General/Governance"
    ),
    
    # Clean Policy Name
    Policy_Name = metric_code %>%
      str_remove("^LEV[1-4]_") %>%
      str_replace_all("_", " ") %>%
      str_to_title()
  )


# Pivoting policy count and stringency so we can be comparing them
oecd_final <- oecd_cleaned %>%
  # Move the measure_type into its own columns
  pivot_wider(
    names_from = measure_type, 
    values_from = value
  ) %>%
  rename(
    count = POL_COUNT,
    stringency = POL_STRINGENCY
  )


oecd_final %>%
  group_by(iso3, Level) %>%
  summarise(
    pct_count_missing = mean(is.na(count)) * 100,
    pct_stringency_missing = mean(is.na(stringency)) * 100
  )


# ============================= Adding official labels from the DSD ============================
library(OECD)

# 1. Fetch the metadata structure for the CAPMF dataset
# This identifier comes from your initial API call
dsd <- get_data_structure("OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0")

# 2. Extract the 'CLIM_ACT_POL' codelist (this houses the labels)
# Note: The name of the list might vary slightly; check names(dsd) if this fails
policy_labels <- dsd$CL_ACT_POL_CAPMF %>%
  rename(
    metric_code = id,
    official_label = label
  )

# 3. Merge this with your 'oecd_ready' dataframe
oecd_final <- oecd_final %>%
  left_join(policy_labels, by = "metric_code") %>%
  # Use the official label for your description or name
  mutate(Policy_Name = coalesce(official_label, Policy_Name))

oecd_final <- oecd_final %>%
  mutate(
    # 1. Clean the Name for charts (Fix casing and punctuation)
    Policy_Name = official_label %>%
      str_replace_all(" - ", ": ") %>%
      str_replace_all("Nox", "NOx") %>%
      str_replace_all("Pm", "Particulate Matter (PM)") %>%
      str_to_title() %>%
      str_replace("Nox", "NOx"), # Fix title case overriding chemical symbols
    
    # 2. Turn Description into a "Policy Type" summary
    Policy_Description = case_when(
      str_detect(metric_code, "EMIS_STD") ~ "Regulatory Emission Limit",
      str_detect(metric_code, "CARBONTAX") ~ "Market-based Carbon Price",
      str_detect(metric_code, "NZ")        ~ "High-level Climate Target",
      TRUE ~ "Climate Policy Instrument"
    )
  )


# ================= Final Integrity & Formatting =================
oecd_final_clean <- oecd_final %>%
  mutate(
    # 1. Clean the Label (the "pretty" version for charts)
    # We use coalesce so if the official_label is missing, we keep our generated one
    Policy_Name = coalesce(official_label, Policy_Name),
    Policy_Name = str_squish(Policy_Name),
    
    # 2. Refine the Description (The "Type" of policy)
    # This provides a broader category for grouping in your analysis
    Policy_Description = case_when(
      str_detect(metric_code, "MBI") ~ "Market-Based Instrument",
      str_detect(metric_code, "NMBI") ~ "Non-Market Regulation",
      str_detect(metric_code, "EMIS_STD") ~ "Regulatory Emission Limit",
      str_detect(metric_code, "CARBONTAX|ETS") ~ "Carbon Pricing",
      str_detect(metric_code, "NZ") ~ "Climate Target",
      TRUE ~ "General Climate Policy"
    )
  ) %>%
  # 3. Final 10-column selection and ordering
  select(
    iso3, year, metric_code, status, Level, Sector, 
    Policy_Name, Policy_Description, stringency, count
  )



# Verify the result
head(oecd_final_clean)

# TODO: cross check for NA values because cpdb might have added info