# ==================== This is for the NDC csv dataset with the liinks to the actual pdfs ====================
library(pdftools)
library(dplyr)
library(purrr)
library(readr)

path_csv <- "02.data/data-raw/ndcs.csv"

# Read the CSV file
ndc_csv_raw <- read_csv(path_csv)
urls <- ndc_csv_raw$'EncodedAbsUrl'

country_list  = TARGET_ISO3

targets <- ndc_csv_raw %>% 
  filter(Code %in% country_list)

# Create an empty list to store the text results
extracted_text_list <- list()

for (i in 1:nrow(targets)) {
  # Get the ISO code and the URL for this row
  country <- targets$Code[i]
  url     <- targets$EncodedAbsUrl[i]
  
  # Define where to save the file
  file_destination <- paste0("02.data/data-raw/ndc_pdfs/", country, ".pdf")
  
  # Download the file
  download.file(url, file_destination, mode = "wb", quiet = TRUE)
  
  # Extract the text
  # pdf_text() gives us a vector where every item is a page
  raw_text <- pdf_text(file_destination)
  
  # Combine all pages into one big block of text
  clean_text <- paste(raw_text, collapse = " ")
  
  # Save it into list with the country name
  extracted_text_list[[country]] <- clean_text
  
  message("Finished: ", country)
}

ndc_text_df <- data.frame(
  iso3 = names(extracted_text_list),
  full_text = unlist(extracted_text_list),
  stringsAsFactors = FALSE
)



# ==================== This is for the IGES NDC dataset ====================
# I need to manually code column names
ndc_labeled <- ndc_raw %>%
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

ndc_final <- ndc_labeled %>%
  mutate(
    # Convert "Afghanistan" -> "AFG", "Germany" -> "DEU"
    iso3 = countrycode(party, origin = "country.name", destination = "iso3c")
  ) %>%
  # Move iso3 to the front for easier reading
  select(iso3, everything())


# Calculating the focus score... this is a bit of a funny method

# NB to remember: the european countries submitted one joint ndc, 

ndc_final_clean <- ndc_final %>%
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
ndc_final_clean %>% 
  filter(iso3 %in% c("CAN", "DEU", "JPN", "ZAF", "IND", "RWA")) %>%
  select(iso3, mitig_word_count, adapt_word_count, adapt_focus_score)
