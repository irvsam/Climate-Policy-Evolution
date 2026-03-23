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



library(tidytext)

# 'Ambition' Dictionary
ambition_lexicon <- tribble(
  ~word, ~type,
  "shall", "strong", "must", "strong", "commit", "strong", "mandatory", "strong", 
  "urgency", "strong", "accelerate", "strong", "target", "strong",
  "should", "soft", "could", "soft", "potential", "soft", "aim", "soft", 
  "consider", "soft", "seek", "soft", "voluntary", "soft"
)

# Tokenize and Score
ndc_ambition <- ndc_results_df %>%
  unnest_tokens(word, full_text) %>%
  inner_join(ambition_lexicon, by = "word") %>%
  group_by(iso3, type) %>%
  summarise(word_count = n(), .groups = "drop") %>%
  pivot_wider(names_from = type, values_from = word_count, values_fill = 0) %>%
  mutate(ambition_score = strong / (strong + soft + 0.001))

# Extract word pairs
ndc_bigrams <- ndc_results_df %>%
  unnest_tokens(bigram, full_text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  # Filter out 'stop words' (the, of, and)
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>%
  unite(bigram, word1, word2, sep = " ")

# Top themes per country
top_themes <- ndc_bigrams %>%
  group_by(iso3, bigram) %>%
  tally(sort = TRUE) %>%
  slice_max(n, n = 5) %>%
  ungroup()



final_analysis <- ndc_comparison %>%
  left_join(ndc_ambition %>% select(iso3, ambition_score), by = "iso3")

library(ggrepel)
ggplot(final_analysis, aes(x = adapt_focus_pct, y = ambition_score, label = iso3)) +
  geom_point(aes(size = total_mentions), color = "steelblue", alpha = 0.7) +
  geom_text_repel() +
  geom_hline(yintercept = mean(final_analysis$ambition_score, na.rm=T), linetype="dashed", alpha=0.3) +
  geom_vline(xintercept = mean(final_analysis$adapt_focus_pct, na.rm=T), linetype="dashed", alpha=0.3) +
  labs(
    title = "National Climate Intent: Adaptation vs. Ambition",
    subtitle = "Analysis of full NDC text (Circle size = Document Volume)",
    x = "Adaptation Focus (%)",
    y = "Ambition Score (Strong vs. Soft Language)"
  ) +
  theme_minimal()



