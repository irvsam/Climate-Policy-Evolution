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
    adaptation_text = ...11,
    mit_fin_text = ...33,
    adapt_fin_text = ...34
  ) %>%
  # Just in case there are empty rows at the bottom
  filter(!is.na(party))

library(countrycode)

ndc_final <- ndc_labeled %>%
  mutate(
    # Convert "Afghanistan" -> "AFG", "Germany" -> "DEU"
    iso3 = countrycode(party, origin = "country.name", destination = "iso3c")
  ) %>%
  # Move iso3 to the front for easier reading
  select(iso3, everything())


# Calculating the focus score... this is a bit of a funny method

library(stringr)

ndc_final <- ndc_final %>%
  mutate(
    # Count words (sequences of characters separated by spaces)
    # Using coalesce to treat NA as 0 words
    mitig_word_count = str_count(coalesce(mitigation_text, ""), "\\w+"),
    adapt_word_count = str_count(coalesce(adaptation_text, ""), "\\w+"),
    
    # Calculate Focus Score: Proportion of adaptation text vs total climate text
    # Add a tiny amount (1) to the denominator to avoid dividing by zero
    adapt_focus_score = adapt_word_count / (mitig_word_count + adapt_word_count + 0.0001)
  )

# Check the results for target countries
ndc_final %>% 
  filter(iso3 %in% c("CAN", "DEU", "JPN", "ZAF", "IND", "RWA")) %>%
  select(iso3, mitig_word_count, adapt_word_count, adapt_focus_score)
