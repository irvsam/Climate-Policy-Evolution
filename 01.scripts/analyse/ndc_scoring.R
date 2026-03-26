
# Turning extracted list into a df
ndc_results_df <- data.frame(
  iso3 = names(ndc_extracted_text_list),
  full_text = unlist(ndc_extracted_text_list),
  stringsAsFactors = FALSE
)

# Let's re think this logic 

# Action Dictionaries

# Creating a subset of words to focus on
adaptation_lexicon <- c("resilience", "vulnerability", "irrigation", "flood", "drought", 
                        "agriculture", "disaster", "infrastructure", "coastal", "ecosystem", 
                        "biodiversity", "health", "water", "forestry", "hazard")

mitigation_lexicon <- c("emissions", "carbon", "renewable", "solar", "wind", 
                        "methane", "decarbonization", "energy", "efficiency", "net-zero", 
                        "sequestration", "low-carbon", "transition")


# For ambition, I am going to create a simple lexicon of "hard" vs. "soft" commitment words. This is a very basic approach but gives a good starting point
ambition_lexicon <- tribble(
  ~word, ~type,
  "must", "hard", "shall", "hard", "mandatory", "hard", "legally", "hard", 
  "commit", "hard", "require", "hard", "obligate", "hard", "mandate", "hard", 
  "enforce", "hard", "binding", "hard", "law", "hard",
  "should", "soft", "could", "soft", "aim", "soft", "seek", "soft", 
  "potential", "soft", "intend", "soft", "aspire", "soft", "encourage", "soft", 
  "promote", "soft", "support", "soft", "policy", "soft"
)

# Tokenization and Scoring
# Remove stop words to focus on meaningful content.
# Stop words comes from the tidytext (e.g., "the", "is", "and").
ndc_tokens <- ndc_results_df %>%
  unnest_tokens(word, full_text) %>%
  filter(!word %in% stop_words$word)

# Focus score
# Important logic: I want to see how much of the text is focused on adaptation vs. mitigation. So I will count the number of adaptation and mitigation words, and then calculate the relative focus on adaptation as a percentage of the total (adaptation + mitigation). 
# This gives a clear metric to compare countries on their relative emphasis on adaptation in their NDCs.

focus_score <- ndc_tokens %>%
  # Categorize each word as adaptation, mitigation, or neither based on the lexicons
  # cat = category
  mutate(cat = case_when(
    word %in% adaptation_lexicon ~ "Adaptation",
    word %in% mitigation_lexicon ~ "Mitigation",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(cat)) %>%
  # Group by country and category, then count the occurrences
  group_by(iso3, cat) %>%
  # This line counts the number of words in each category for each country
  summarise(n = n(), .groups = "drop") %>%
  # Reshape the data to have separate columns for Adaptation and Mitigation counts
  pivot_wider(names_from = cat, values_from = n, values_fill = 0) %>%
  mutate(relative_adapt_focus = Adaptation / (Adaptation + Mitigation))

# Ambition Scoring
# For ambition, I want to see how much "hard" language vs. "soft" language is used in the NDCs. So I will count the number of hard and soft words, and then calculate an ambition score as the ratio of hard words to total (hard + soft)
ambition_score <- ndc_tokens %>%
  # Join with the ambition lexicon to categorize words as hard or soft
  inner_join(ambition_lexicon, by = "word") %>%
  group_by(iso3, type) %>%
  # Count the number of hard and soft words for each country
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = type, values_from = count, values_fill = 0) %>%
  # Adding a small constant to the denominator to avoid division by zero.
  mutate(ambition_score = hard / (hard + soft + 0.001))

# Join
final_map_df <- focus_score %>%
  left_join(ambition_score, by = "iso3")

# Final cleanup of the data before plotting
final_map_df <- final_map_df %>%
  mutate(
    # If ambition_score is NA, make it 0 so it stays on the map
    ambition_score = replace_na(ambition_score, 0),
    # Ensure relative_adapt_focus is also clean
    relative_adapt_focus = replace_na(relative_adapt_focus, 0)
  )

# Verify IND is still there
print(final_map_df %>% filter(iso3 == "IND"))

# Instead of focusing on how much they are adaptation or mitigation I want to just focus on how much adaptation has been brought into their language relative to the others

ndc_adaptation_leaderboard <- ggplot(final_map_df, aes(x = reorder(iso3, relative_adapt_focus), y = relative_adapt_focus)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "The Adaptation Leaderboard",
       subtitle = "Relative share of adaptation vs. mitigation keywords in NDC",
       x = "Country", y = "Relative Adaptation Focus") +
  theme_minimal()

ndc_ambition_vs_focus <- ggplot(final_map_df, aes(x = relative_adapt_focus, y = ambition_score, label = iso3)) +
  # Strategic Zones
  annotate("rect", xmin=0.5, xmax=1.05, ymin=0.5, ymax=1.05, fill="blue", alpha=0.05) + # Potential Adaptation Leaders
  annotate("rect", xmin=-0.05, xmax=0.5, ymin=0.5, ymax=1.05, fill="green", alpha=0.05) + # Mitigation Hardliners
  
  # Data Points
  geom_point(size = 5, color = "#2c3e50", alpha = 0.8) +
  
  # Smart Labeling to fix clustering
  geom_text_repel(
    fontface = "bold", 
    size = 4,
    box.padding = 0.5, 
    point.padding = 0.5,
    force = 15,
    segment.color = 'grey50'
  ) +
  
  # Reference Lines
  geom_vline(xintercept = 0.5, linetype = "dashed", alpha = 0.3) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.3) +
  
  # Scales and Formatting
  scale_x_continuous(labels = scales::percent, limits = c(0, 1.05)) +
  scale_y_continuous(limits = c(0, 1.05)) +
  labs(
    title = "Climate Ambition Matrix: Lexical Hardness vs. Focus",
    subtitle = "Triangulating NDC Strategic Intent with Mandatory vs. Aspirational Language",
    x = "Relative Adaptation Focus (%)",
    y = "Ambition Score (Ratio of Hard vs. Soft Language)",
  ) +
  theme_minimal()



# Which countries got dropped from the graph?
countries_in_graph <- final_map_df$iso3
countries_dropped <- setdiff(TARGET_ISO3, countries_in_graph)

