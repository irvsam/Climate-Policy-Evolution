# Here I am going to set up the connections to the APIs that I will be using in this project. 


# =============================== OECD CAPMF API ====================================================================================
# This one requires using their api online and applying filters to get the data I need. 

oecd_url <- "https://sdmx.oecd.org/public/rest/data/OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0/DEU+ZAF+IND+JPN+CAN+SAU+COL+DNK+CHL+USA+GBR.A.POL_COUNT+POL_STRINGENCY..0_TO_10+PL"

message("Fetching data from OECD CAPMF...")
oecd_req <- request(oecd_url) %>%
  req_url_query(
    startPeriod = "2012",
    endPeriod = "2023",
    dimensionAtObservation = "AllDimensions"
  ) %>%
  req_headers("Accept" = "text/csv")

oecd_resp <- req_perform(oecd_req)

oecd_df_collected <- resp_body_string(oecd_resp) %>%
  read_csv(show_col_types = FALSE)

# ====================================== CPDB API: =====================================================================================

message("Setting up CPDB Python API...")

# Setup
# Check if the cpdb_ap module is available in the current Python environment
if (!py_module_available("cpdb_api")) {
  message("cpdb_api not found. Installing now...")
  py_install("cpdb-api")
}
cpdb <- import("cpdb_api")

fetch_global_time_range <- function(start_year, end_year) {
  cat("Fetching global policies from", start_year, "to", end_year, "...\n")

  years <- seq(start_year, end_year)
  
  all_data <- map(years, function(yr) {
    cat("  Processing year:", yr, "\n")
    r_yr <- cpdb$request$Request()
    r_yr$set_decision_date(as.integer(yr))
    
    tryCatch({
      return(r_yr$issue())
    }, error = function(e) {
      message("  No data or error for year ", yr)
      return(NULL)
    })
  })
  
  return(bind_rows(all_data))
}

# Collect global data for the time period
cpdb_df_collected <- fetch_global_time_range(2013, 2025)


# =============================== world bank API =====================================================================================



message("Calculating Cumulative GGE (2013-2025)...")


target_indicator <- "WB_WDI_EN_GHG_ALL_MT_CE_AR5"
# Create a comma-separated string of ISO3 codes for the API query
iso_string <- paste(TARGET_ISO3, collapse = ",")

ghg_resp <- request("https://data360api.worldbank.org/data360/data") %>%
  req_url_query(
    DATABASE_ID = "WB_WDI",
    INDICATOR = target_indicator,
    REF_AREA = iso_string,
    timePeriodFrom = "2013", 
    timePeriodTo = "2025"
  ) %>%
  req_perform()

ghg_content <- resp_body_json(ghg_resp, simplifyVector = TRUE)

if (ghg_content$count > 0) {
  # Calculate Cumulative Sum
  ghg_cumulative <- ghg_content$value %>%
    # Convert to tibble for easier manipulation
    as_tibble() %>%
    # Make numerical for calculations
    mutate(OBS_VALUE = as.numeric(OBS_VALUE),
           TIME_PERIOD = as.numeric(TIME_PERIOD)) %>%
    group_by(REF_AREA) %>%
    # Using sum() to get the total since 2013
    summarise(
      cumulative_ghg = sum(OBS_VALUE, na.rm = TRUE),
      data_points_count = n(),
      # Get the latest year available for each country so I know which year the cumulative sum is up to
      latest_year = max(TIME_PERIOD),
      .groups = "drop"
    ) %>%
    select(iso3 = REF_AREA, total_ghg = cumulative_ghg, latest_year)
  
  message("Cumulative data successfully calculated.")
}

message("Data collection complete.")



