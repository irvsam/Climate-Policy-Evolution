
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
# For ambition, I want to see how much "hard" language vs. "soft" language is used in the NDCs. 
# So I will count the number of hard and soft words, and then calculate an ambition score as the ratio of hard words to total (hard + soft)
# UPDATE: The scores weren't very useful so I am now also going to normalize this ambition score by the average across all countries so that I can see which countries are above or below average in their use of hard language relative to soft language. 
ambition_score <- ndc_tokens %>%
  inner_join(ambition_lexicon, by = "word") %>%
  group_by(iso3, type) %>%
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = type, values_from = count, values_fill = 0) %>%
  # Use a log-ratio or a centered ratio to see 'relative' hardness
  mutate(raw_ratio = hard / (hard + soft + 0.001)) %>%
  mutate(ambition_score = raw_ratio / mean(raw_ratio)) # Scores > 1 are 'Above Average' Hardness

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


# Instead of focusing on how much they are adaptation or mitigation I want to just focus on how much adaptation has been brought into their language relative to the others

leaderboard_with_vulnerability <- final_map_df %>%
  left_join(ndgain_final_clean %>% filter(year == 2023), by = c("iso3" = "iso3")) %>%
  mutate(resilience_tier = case_when(
    score > 60 ~ "High Resilience",
    score > 50 ~ "Moderate Resilience",
    TRUE ~ "Low Resilience"
  )) %>%
  # Handle any NAs from the join
  filter(!is.na(relative_adapt_focus))

# Create Enhanced Leaderboard

resilience_palette <- c(
  "Low Resilience" = "#d35400", 
  "Moderate Resilience" = "#f39c12", 
  "High Resilience" = "#2980b9"
)


ndc_adaptation_leaderboard <- ggplot(leaderboard_with_vulnerability, 
                                        aes(x = reorder(iso3, relative_adapt_focus), 
                                            y = relative_adapt_focus, 
                                            fill = resilience_tier)) +
  geom_col() + # Use geom_col for pre-calculated values
  coord_flip() + 
  scale_y_continuous(labels = scales::percent) +
  # Using your requested color palette
  scale_fill_manual(values = resilience_palette, name = "Climate Resilience (ND-GAIN)") +
  labs(
    title = "The Adaptation Leaderboard: Intent vs. Vulnerability",
    subtitle = "Relative Adaptation Focus (NLP) colored by ND-GAIN Vulnerability Tier",
    x = "Country (ISO-3)",
    y = "Relative Adaptation Focus (% of Climate Lexicon)",
    fill = "Climate Need"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")


# Calculate medians 
x_med <- median(final_map_df$relative_adapt_focus)
y_med <- median(final_map_df$ambition_score)


final_map_df <- final_map_df %>%
  mutate(
    focus_type = if_else(relative_adapt_focus > x_med, "Adaptation", "Mitigation"),
    is_above_average_hardness = ambition_score > y_med
  )


# New Neutral Palette for the Matrix
matrix_palette <- c("Adaptation" = "#8e44ad", "Mitigation" = "#16a085") # Purple & Teal

ndc_ambition_vs_focus <- ggplot(final_map_df, aes(x = relative_adapt_focus, 
                                                  y = ambition_score, 
                                                  label = iso3, 
                                                  color = focus_type)) +
  
  # Data Points with a slight outline for clarity
  geom_point(size = 4, alpha = 0.7) +
  scale_color_manual(values = matrix_palette, name = "Strategic Focus") +
  
  # Improve Text Repel: lower force, add box padding
  geom_text_repel(
    fontface = "bold", 
    size = 3.5,
    box.padding = 0.4, 
    point.padding = 0.3,
    force = 5,           # Lowered force prevents labels from flying away
    show.legend = FALSE
  ) +
  
  # Reference Lines
  geom_vline(xintercept = x_med, linetype = "dotted", color = "grey50") +
  geom_hline(yintercept = y_med, linetype = "dotted", color = "grey50") +
  
  # Layout - Fixing the Aspect Ratio
  coord_cartesian(clip = "off") + 
  scale_x_continuous(labels = scales::percent, limits = c(0, 1), 
                     expand = expansion(mult = c(0.05, 0.1))) +
  scale_y_continuous(limits = c(0, NA), 
                     expand = expansion(mult = c(0.1, 0.1))) +
  
  labs(
    title = "The Ambition Matrix: Lexical Hardness vs. Focus",
    subtitle = "Dashed lines represent group medians. Colored by primary focus.",
    x = "Adaptation Focus (Text %)",
    y = "Relative Lexical Hardness (Index)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    # This helps the plot stay 'balanced' on the PDF page
    aspect.ratio = 0.7, 
    plot.title = element_text(face = "bold", size = 14),
    plot.margin = margin(20, 50, 20, 20)
  )

print(ndc_ambition_vs_focus)
