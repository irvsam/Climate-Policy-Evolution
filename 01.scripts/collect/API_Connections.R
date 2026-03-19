# Here I am going to set up the connections to the APIs that I will be using in this project. 

library(vctrs)
library(dplyr)
library(reticulate)
library(httr2)
library(readr)

# List of countries I think will be most relevant to my project, based on the criteria I outlined in my proposal. 
country_list <- c(
  "RWA", # Rwanda: Primary case study (Unitary, High Vulnerability)
  "DEU", # Germany: Global North leader (Federal, High Mitigation Stringency)
  "IND", # India: Global South power (Federal, High Growth/Sectoral Complexity)
  "BRA", # Brazil: Land-Use Focus (Federal, High Biodiversity/Adaptation Significance)
  "ZAF", # South Africa: Just Transition Model (Unitary, Coal-to-Green Transition focus)
  "JPN", # Japan: Vulnerable North (Unitary, Technology-led Adaptation)
  "CAN"  # Canada: Federal Resource Exporter (Federal, Mitigation/Adaptation tension)
)

# Added: DNK (Leader), GBR (G20 Leader), CHL (Reg. Leader), COL (Dev. Leader), USA (Underperformer), SAU (Underperformer)

target_countries <- c("CAN", "DEU", "JPN", "IND", "ZAF", "DNK", "GBR", "CHL", "COL", "USA", "SAU")
# I will be using the following APIs: OECD CAPMF, CPDB, ND-GAIN, UNFCCC NDCs

# =============================== OECD CAPMF API ====================================================================================
# This one requires using their api online and applying filters to get the data I need. 
# I will be using the following filters: 

# Countries are all those in the list minus Rwanda (because they are not in the OECD)
# Time period 2015 - 2023
# Measure: Policy stringency and adopted policies
# I am collecting data on all the policies so this will not be a filter
# Unit of measure: policies and 0-10

refined_url <- "https://sdmx.oecd.org/public/rest/data/OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0/DEU+ZAF+IND+JPN+CAN+SAU+COL+DNK+CHL.A.POL_COUNT+POL_STRINGENCY..0_TO_10+PL"

req <- request(refined_url) %>%
  req_url_query(
    startPeriod = "2012",
    endPeriod = "2023",
    dimensionAtObservation = "AllDimensions"
  ) %>%
  req_headers("Accept" = "text/csv")

resp <- req_perform(req)
oecd_df_granular <- resp_body_string(resp) %>%
  read_csv(show_col_types = FALSE)



# ====================================== CPDB API: =====================================================================================

# ============================== cpdc without country filters ====================================================================================

library(reticulate)
library(dplyr)

# Setup
cpdb <- import("cpdb_api")

fetch_global_time_range <- function(start_year, end_year) {
  cat("Fetching global policies from", start_year, "to", end_year, "...\n")
  
  r <- cpdb$request$Request()
  
  # By NOT calling r$set_country(), the API defaults to all available countries.
  
  years <- seq(start_year, end_year)
  
  all_data <- lapply(years, function(yr) {
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
  
  # Combine the list of dataframes into one master dataframe
  return(bind_rows(all_data))
}

#Get global data for the last decade
global_policy_df <- fetch_global_time_range(2013, 2025)



