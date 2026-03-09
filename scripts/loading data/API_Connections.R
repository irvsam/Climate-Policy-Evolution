# Here I am going to set up the connections to the APIs that I will be using in this project. 


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

# OECD CAPMF API
# This one requires using their api online and applying filters to get the data I need. 
# I will be using the following filters: 

# Countries are all those in the list minus Rwanda (because they are not in the OECD)
# Time period 2015 - 2023
# Measure: Policy stringency and adopted policies
# I am collecting data on all the policies so this will not be a filter
# Unit of measure: policies and 0-10

# After applying all of those filters you get a flat SDMX data query
# long url = "https://sdmx.oecd.org/public/rest/data/OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0/DEU+ZAF+IND+BRA+JPN+CAN.A.POL_COUNT+POL_STRINGENCY.LEV2_CROSS_SEC_GHGTAR+LEV2_CROSS_SEC_RDD+LEV2_CROSS_SEC_FFPP+LEV2_CROSS_SEC_CG+LEV2_INT_C_COORD+LEV2_INT_C_FIN+LEV2_INT_GHGREP+LEV3_BAN_PHOUT_COAL+LEV3_RENEWABLE_EXP+LEV3_EMIS_STD+LEV3_ETS_I+LEV3_CARBONTAX_I+LEV3_FFS_I+LEV3_EXCISETAX_I+LEV3_FIN_MECH_I+LEV3_MEPS_MOTOR+LEV3_EE_MANDATE+LEV3_ETS_B+LEV3_CARBONTAX_B+LEV3_FFS_B+LEV3_EXCISETAX_B+LEV3_FIN_MECH_B+LEV3_MEPS_APPL+LEV3_BC+LEV3_BAN_PHOUT_HEAT+LEV3_LABEL_APPL+LEV3_CONG_CHARG+LEV3_ETS_T+LEV3_CARBONTAX_T+LEV3_FFS_T+LEV3_EXCISETAX_T+LEV3_MEPS_T+LEV3_LABEL_CAR+LEV3_EXP_RAIL+LEV3_SPEED+LEV3_BAN_PHOUT_ICE+LEV3_NDC+LEV3_NZ+LEV3_RDD_EE+LEV3_RDD_CCS+LEV3_RDD_RES+LEV3_RDD_NUC+LEV3_RDD_HYDR+LEV3_RDD_OTHER+LEV3_BAN_PHOUT_EXTRAC+LEV3_FFS_PRODUCER+LEV3_METHAN+LEV3_AB+LEV3_TREATY+LEV3_INT_INIT+LEV3_PR_AV_MAR+LEV3_BAN_CREDIT+LEV3_BAN_FF_ABROAD+LEV3_EVAL_BR+LEV3_UNFCCC+LEV3_GHG_ACC+LEV4_FIT_SOL_PR+LEV4_FIT_SOL_DUR+LEV4_FIT_WIND_PR+LEV4_FIT_WIND_DUR+LEV4_AUCTION_SOL_PR+LEV4_AUCTION_SOL_DUR+LEV4_AUCTION_WIND_PR+LEV4_AUCTION_WIND_DUR+LEV4_RECS+LEV4_CARBONTAX_E_PR+LEV4_FFS_E+LEV4_EXCISETAX_E_COAL+LEV4_EXCISETAX_E_NATGAS+LEV4_BAN_COAL_DATE+LEV4_BAN_COAL_STAT+LEV4_PHOUT_COAL_DATE+LEV4_PHOUT_COAL_STAT+LEV4_RENEWABLE_EXP+LEV4_EMIS_STD_NOX+LEV4_EMIS_STD_SOX+LEV4_EMIS_STD_PM+LEV4_ETS_I_PR+LEV4_ETS_I_GHG+LEV4_CARBONTAX_I+LEV4_FFS_I+LEV4_EXCISETAX_I_COAL+LEV4_EXCISETAX_I_NATGAS+LEV4_EXCISETAX_I_DIESEL+LEV4_FIN_MECH_I+LEV4_MEPS_MOTOR+LEV4_EE_MANDATE+LEV4_ETS_B_PR+LEV4_ETS_B_GHG+LEV4_CARBONTAX_B+LEV4_FFS_B+LEV4_EXCISETAX_B_C_COAL+LEV4_EXCISETAX_B_R_COAL+LEV4_EXCISETAX_B_C_DIESEL+LEV4_EXCISETAX_B_R_DIESEL+LEV4_EXCISETAX_B_C_LPG+LEV4_EXCISETAX_B_R_LPG+LEV4_EXCISETAX_B_C_NATGAS+LEV4_EXCISETAX_B_R_NATGAS+LEV4_FIN_MECH_B_R+LEV4_FIN_MECH_B_C+LEV4_MEPS_FRE+LEV4_MEPS_REF+LEV4_MEPS_LIGHT+LEV4_MEPS_AC+LEV4_BC_RES+LEV4_BC_NON_RES+LEV4_BAN_OIL_DATE+LEV4_BAN_OIL_STAT+LEV4_BAN_GAS_DATE+LEV4_BAN_GAS_STAT+LEV4_PHOUT_OIL_DATE+LEV4_PHOUT_OIL_STAT+LEV4_PHOUT_GAS_DATE+LEV4_PHOUT_GAS_STAT+LEV4_LABEL_FRE+LEV4_LABEL_REF+LEV4_LABEL_LIGHT+LEV4_LABEL_AC+LEV4_CONG_CHARG+LEV4_ETS_T_PR+LEV4_ETS_T_GHG+LEV4_CARBONTAX_T+LEV4_FFS_T+LEV4_EXCISETAX_T_DIESEL+LEV4_EXCISETAX_T_GASO+LEV4_MEPS_LDV+LEV4_MEPS_HDV+LEV4_LABEL_CAR+LEV4_EXP_RAIL+LEV4_SPEED+LEV4_BAN_ICE_DATE+LEV4_BAN_ICE_STAT+LEV4_PHOUT_ICE_DATE+LEV4_PHOUT_ICE_STAT+LEV4_NDC_LULUCF+LEV4_NDC_SCOPE_SEC+LEV4_NDC_SCOPE_EMIS+LEV4_NDC_SING_MULT+LEV4_NDC_TARG_TYPE+LEV4_NDC_DET+LEV4_NZ_GHG_SCOPE+LEV4_NZ_SEC_SCOPE+LEV4_NZ_DATE+LEV4_NZ_STAT+LEV4_RDD_EE+LEV4_RDD_CCS+LEV4_RDD_RES+LEV4_RDD_NUC+LEV4_RDD_HYDR+LEV4_RDD_OTHER+LEV4_BAN_EXTRAC_DATE+LEV4_BAN_EXTRAC_STAT+LEV4_PHOUT_EXTRAC_DATE+LEV4_PHOUT_EXTRAC_STAT+LEV4_FFS_PRODUCER+LEV4_METHAN+LEV4_AB_ESTABL+LEV4_AB_ESTABL_LAW+LEV4_AB_SECR_MEM+LEV4_AB_COUNC_MEM+LEV4_AB_BUDGET+LEV4_TREATY_UNFCCC+LEV4_TREATY_MONTREALPROT+LEV4_TREATY_MONTREALAMEND+LEV4_TREATY_KIGALI+LEV4_TREATY_KYOTO+LEV4_TREATY_PARIS+LEV4_INT_INIT+LEV4_PR_AV+LEV4_PR_MAR+LEV4_PR_CORSIA+LEV4_BAN_CREDIT_STAT+LEV4_BAN_CREDIT_DATE+LEV4_BAN_FF_ABROAD_STAT+LEV4_BAN_FF_ABROAD_DATE+LEV4_EVAL_BR+LEV4_UNFCCC_GHGINV+LEV4_UNFCCC_BR+LEV4_UNFCCC_NC+LEV4_UNFCCC_NDC+LEV4_UNFCCC_LTLEDS+LEV4_GHG_ACC_ANNEX+LEV4_GHG_ACC_SEEA+LEV1_SEC+LEV2_SEC_E_MBI+LEV3_ETS_E+LEV4_ETS_E_PR+LEV4_ETS_E_GHG+LEV3_CARBONTAX_E+LEV3_FFS_E+LEV3_EXCISETAX_E+LEV3_FIT+LEV3_AUCTION+LEV3_RECS+LEV2_SEC_E_NMBI+LEV2_SEC_I_MBI+LEV2_SEC_I_NMBI+LEV2_SEC_B_MBI+LEV2_SEC_B_NMBI+LEV2_SEC_T_MBI+LEV2_SEC_T_NMBI+LEV1_CROSS_SEC+LEV1_INT.0_TO_10+PL?startPeriod=2015&endPeriod=2023&dimensionAtObservation=AllDimensions?format=jsondata"
# I added on ?format=jsondata to the end of the url to get the data in json format

library(vctrs)
library(dplyr)

library(httr2)
library(readr)

# Use the new OECD SDMX endpoint directly
url <- "https://sdmx.oecd.org/public/rest/data/OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0/DEU+ZAF+IND+BRA+JPN+CAN.A.POL_COUNT+POL_STRINGENCY.LEV1_SEC.0_TO_10+PL?startPeriod=2015&endPeriod=2023&dimensionAtObservation=AllDimensions"

req <- request("https://sdmx.oecd.org/public/rest/data/OECD.ENV.EPI,DSD_CAPMF@DF_CAPMF,1.0/DEU+ZAF+IND+BRA+JPN+CAN.A.POL_COUNT+POL_STRINGENCY.LEV1_SEC.0_TO_10+PL") %>%
  req_url_query(
    startPeriod = "2015",
    endPeriod = "2023",
    dimensionAtObservation = "AllDimensions"
  ) %>%
  req_headers("Accept" = "text/csv")

# Perform the request
resp <- req_perform(req)
# Read the CSV directly from the response body
oecd_df <- resp_body_string(resp) %>%
  read_csv(show_col_types = FALSE)

head(oecd_df)


# CPDB API: for this one I will need to use the reticulate pakage


install.packages("reticulate")
library(reticulate)

# Install the Python package 
py_install("cpdb-api")

# Import the Python library
cpdb <- import("cpdb_api")

# # Initialize the request object
# r <- cpdb$request$Request()
# 
# # # Apply filters (using the example from the api docs for now)
# # r$set_country("IND")
# # r$set_decision_date(2010)
# # r$set_policy_status("In force")
# # r$add_sector("Electricity and heat")
# # r$add_sector("Coal")
# # r$add_policy_instrument("Energy and other taxes")
# # r$add_mitigation_area("Renewables")
# 
# # Issue the request
# cpdb_df <- r$issue()
# 
# print(head(cpdb_df))


# Now let's try get a full df with all the countries we are interested in

library(purrr) # Useful for iterating over combinations of countries and years

year_list <- 2015:2026

# Create a grid of all combinations (e.g., DEU-2015, DEU-2016, ...)
search_grid <- expand.grid(country = country_list, year = year_list)

# Function for getting data from each entry in country-year grid
fetch_cpdb_data <- function(country, year) {
  cat("Fetching data for:", country, "| Year:", year, "\n")
  
  r <- cpdb$request$Request()
  r$set_country(country)
  r$set_decision_date(as.integer(year)) # Ensure it's an integer
  r$set_policy_status("In force")
  
  tryCatch({
    df <- r$issue()
    # Add columns so we know which year/country this data belongs to later
    if (!is.null(df)) {
      df$query_year <- year
      return(df)
    }
  }, error = function(e) return(NULL))
}

# Iterate over the grid
cpdb_master_df <- pmap_dfr(search_grid, fetch_cpdb_data)

# Check the results
head(cpdb_master_df)
