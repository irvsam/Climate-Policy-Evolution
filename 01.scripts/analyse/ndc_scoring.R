library(stringr)
library(tidyr)

# Turning extracted list into a df
ndc_results_df <- data.frame(
  iso3 = names(extracted_text_list),
  full_text = unlist(extracted_text_list),
  stringsAsFactors = FALSE
)

# Let's re think this logic 

# Action Dictionaries
adaptation_lexicon <- c("resilience", "vulnerability", "irrigation", "flood", "drought", 
                        "agriculture", "disaster", "infrastructure", "coastal")

mitigation_lexicon <- c("emissions", "carbon", "renewable", "solar", "wind", 
                        "methane", "decarbonization", "energy", "efficiency")

ambition_lexicon <- tribble(
  ~word, ~type,
  "must", "hard", "mandatory", "hard", "legally", "hard", "shall", "hard", "commit", "hard",
  "should", "soft", "could", "soft", "aim", "soft", "seek", "soft", "potential", "soft"
)

# Tokenization and Scoring
ndc_tokens <- ndc_results_df %>%
  unnest_tokens(word, full_text) %>%
  filter(!word %in% stop_words$word)

