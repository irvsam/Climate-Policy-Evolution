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
# I will be using the following APIs: OECD CAPMF, CPDB, ND-GAIN, UNFCCC NDCs

# =============================== OECD CAPMF API ====================================================================================
# This one requires using their api online and applying filters to get the data I need. 
# I will be using the following filters: 

# Countries are all those in the list minus Rwanda (because they are not in the OECD)
# Time period 2015 - 2023
# Measure: Policy stringency and adopted policies
# I am collecting data on all the policies so this will not be a filter
# Unit of measure: policies and 0-10

refined_url <- "https://sdmx.oecd.org/public/rest/data/OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0/DEU+ZAF+IND+BRA+JPN+CAN.A.POL_COUNT+POL_STRINGENCY..0_TO_10+PL"

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
#for this one I will need to use the reticulate pakage


# Install the Python package 
py_install("cpdb-api")

# Import the Python library
cpdb <- import("cpdb_api")

# Now let's try get a full df with all the countries we are interested in

library(purrr) # Useful for iterating over combinations of countries and years

year_list <- 2012:2026

# Create a grid of all combinations (e.g., DEU-2015, DEU-2016, ...)
search_grid <- expand.grid(country = country_list, year = year_list)

# Function for getting data from each entry in country-year grid
fetch_cpdb_data <- function(country, year) {
  cat("Fetching data for:", as.character(country), "| Year:", as.character(year), "\n")
  
  r <- cpdb$request$Request()
  r$set_country(country)
  r$set_decision_date(as.integer(year)) # Ensure it's an integer
  # r$set_policy_status("In force")
  
  tryCatch({
    df <- r$issue()
    # Add columns so we know which year/country this data belongs to later
    if (!is.null(df)) {
      df$query_year <- year
      df$query_country <- country # Added this to make sure we know which country the data is from
      return(df)
    }
  }, error = function(e) return(NULL))
}

# Iterate over the grid
cpdb_master_df <- pmap_dfr(search_grid, fetch_cpdb_data)

