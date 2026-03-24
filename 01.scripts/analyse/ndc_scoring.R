
# Turning extracted list into a df
ndc_results_df <- data.frame(
  iso3 = names(ndc_extracted_text_list),
  full_text = unlist(ndc_extracted_text_list),
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

#Focus score
focus_score <- ndc_tokens %>%
  mutate(cat = case_when(
    word %in% adaptation_lexicon ~ "Adaptation",
    word %in% mitigation_lexicon ~ "Mitigation",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(cat)) %>%
  group_by(iso3, cat) %>%
  summarise(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = cat, values_from = n, values_fill = 0) %>%
  mutate(relative_adapt_focus = Adaptation / (Adaptation + Mitigation))

# Ambition Scoring
ambition_score <- ndc_tokens %>%
  inner_join(ambition_lexicon, by = "word") %>%
  group_by(iso3, type) %>%
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = type, values_from = count, values_fill = 0) %>%
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
  # Add shaded areas to show 'Strategic Zones'
  annotate("rect", xmin=0.5, xmax=1, ymin=0.5, ymax=1, fill="blue", alpha=0.1) + # Adaptation Leaders
  annotate("rect", xmin=0, xmax=0.5, ymin=0.5, ymax=1, fill="green", alpha=0.1) + # Mitigation Leaders
  geom_point(size = 4, color = "#2c3e50") +
  geom_text_repel(fontface = "bold") +
  geom_vline(xintercept = 0.5, linetype = "dashed", alpha = 0.4) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.4) +
  scale_x_continuous(labels = scales::percent) +
  labs(
    title = "Mapping Climate Ambition & Focus",
    subtitle = "Relative Adaptation Focus vs. Hard Commitment Score",
    x = "Relative Adaptation Focus (%)",
    y = "Ambition Score (Hard vs. Soft Language)"
  ) +
  theme_minimal()
