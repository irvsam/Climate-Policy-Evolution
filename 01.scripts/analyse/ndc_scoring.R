library(stringr)
library(tidyr)

# Turning extracted list into a df
ndc_results_df <- data.frame(
  iso3 = names(extracted_text_list),
  full_text = unlist(extracted_text_list),
  stringsAsFactors = FALSE
)

# Count the words (Simple Logic)
ndc_comparison <- ndc_results_df %>%
  mutate(
    # Count "Adaptation" (and "Adapt", "Adaptive", etc.)
    adapt_count = str_count(full_text, regex("adapt", ignore_case = TRUE)),
    # Count "Mitigation" (and "Mitigate", etc.)
    mitig_count = str_count(full_text, regex("mitigat", ignore_case = TRUE)),
    
    # Calculate the Focus (Percentage)
    total_mentions = adapt_count + mitig_count,
    adapt_focus_pct = (adapt_count / total_mentions) * 100
  )

# Adaptation Leaderboard
print(ndc_comparison %>% select(iso3, adapt_count, mitig_count, adapt_focus_pct) %>% arrange(desc(adapt_focus_pct)))
