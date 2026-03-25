# ==================== This is for the NDC csv dataset with the links to the actual pdfs ====================


path_csv <- "02.data/data-raw/ndcs.csv"
# Read the CSV file
ndc_csv_raw <- read_csv(path_csv)
urls <- ndc_csv_raw$'EncodedAbsUrl'
dir.create("02.data/data-preprocessed/ndc_downloads", recursive = TRUE, showWarnings = FALSE)
country_list  = TARGET_ISO3

targets <- ndc_csv_raw %>% 
  filter(Code %in% country_list)

# Create an empty list to store the text results
ndc_extracted_text_list <- list()

# Need to clean up the targets so we only looking at the ones that are active, in english
# COL only has an archived one in english so we need to keep that one
# Need to make sure columbia is not removed
targets <- targets %>%
  filter(Language == "English", Status == "Active" | (Code == "COL" & Status == "Archived"))

# Now also just keep the earliest submission date
targets <- targets %>%
  group_by(Code) %>%
  slice_min(order_by = `SubmissionDate`, n = 1) %>%
  ungroup()


# Let's just try see how to get the url and open it... i think we need to use httr to get the content and then pass it to pdftools

for (i in 1:nrow(targets)) {
  url <- targets$EncodedAbsUrl[i]
  country_code <- targets$Code[i]
  file_path <- paste0("02.data/data-preprocessed/ndc_downloads/", country_code, ".pdf")
  
  # Download directly to the disk
  response <- GET(url, 
                  write_disk(file_path, overwrite = TRUE),
                  user_agent("Mozilla/5.0"))
  
  if (status_code(response) == 200) {
    # Try to extract text
    txt <- try(pdf_text(file_path), silent = TRUE)
    
    if (class(txt) != "try-error") {
      # Combine pages and save
      ndc_extracted_text_list[[country_code]] <- paste(txt, collapse = " ")
      message("Success: ", country_code)
    } else {
      message("Extraction failed for: ", country_code)
    }
  } else {
    message("Download failed for: ", country_code, " Code: ", status_code(response))
  }
}



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


# NB to remember: the european countries submitted one joint ndc, 
ndc_iges_final_clean <- ndc_final %>%
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
ndc_iges_final_clean %>% 
  filter(iso3 %in% c("CAN", "DEU", "JPN", "ZAF", "IND", "RWA")) %>%
  select(iso3, mitig_word_count, adapt_word_count, adapt_focus_score)

message("--- NDC Cleaning Complete ---")
