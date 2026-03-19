library(readxl)
library(dplyr)
library(tidyr)
library(janitor)

path <- "02.data/data-raw/IGESNDC.xlsx" 

# Read the file starting from the first actual data row (Afghanistan)
ndc_raw_clean <- read_excel(path, 
                            sheet = "NDC MASTER SHEET", 
                            skip = 4, 
                            col_names = FALSE)

# Now I need to manually code column names

ndc_labeled <- ndc_raw_clean %>%
  select(
    party = ...1, 
    region = ...2, 
    mitigation_text = ...10, 
    adaptation_text = ...11
  ) %>%
  # Just in case there are empty rows at the bottom
  filter(!is.na(party))

install.packages("countrycode")
library(countrycode)

ndc_final <- ndc_labeled %>%
  mutate(
    # Convert "Afghanistan" -> "AFG", "Germany" -> "DEU"
    iso3 = countrycode(party, origin = "country.name", destination = "iso3c")
  ) %>%
  # Move iso3 to the front for easier reading
  select(iso3, everything())
