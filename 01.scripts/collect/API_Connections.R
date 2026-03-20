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


message("Data collection complete.")



