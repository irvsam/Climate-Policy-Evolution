# I now have the clean dataset ready to analyze the evolution of policies over time.

library(dplyr)
library(ggplot2)
library(tidyr)

# Load the cleaned CPDB data
cpdb_clean <- readRDS("02.data/data-preprocessed/cpdb_clean.rds")

# Define adaptation-inclusive policies and calculate cumulative counts
adaptation_growth <- cpdb_clean %>%
  filter(!is.na(decision_date)) %>%
  # Flag anything that is 'adaptation' or 'both'
  mutate(has_adaptation = ifelse(policy_type %in% c("adaptation", "both"), 1, 0)) %>%
  group_by(decision_date) %>%
  summarise(yearly_count = sum(has_adaptation), .groups = 'drop') %>%
  arrange(decision_date) %>%
  mutate(cumulative_adaptation = cumsum(yearly_count))


# Do the same for Mitigation for a baseline comparison
mitigation_growth <- cpdb_clean %>%
  filter(!is.na(decision_date)) %>%
  mutate(has_mitigation = ifelse(policy_type %in% c("mitigation", "both"), 1, 0)) %>%
  group_by(decision_date) %>%
  summarise(yearly_count = sum(has_mitigation), .groups = 'drop') %>%
  arrange(decision_date) %>%
  mutate(cumulative_mitigation = cumsum(yearly_count))

adaptation_growth <- adaptation_growth %>%
  mutate(decision_date = as.integer(as.character(decision_date)))

mitigation_growth <- mitigation_growth %>%
  mutate(decision_date = as.integer(as.character(decision_date)))

ggplot(adaptation_growth, aes(x = decision_date, y = cumulative_adaptation)) +
  geom_line(color = "#e67e22", size = 1.2) +
  geom_point(color = "#e67e22", size = 2, alpha = 0.5) +
  labs(
    title = "Global Cumulative Growth of Adaptation-Related Policies",
    subtitle = "Includes policies labeled as 'adaptation' and 'both'",
    x = "Year",
    y = "Total Number of Policies (Cumulative)"
  ) +
  # This line ensures every year from 2013 to 2025 is displayed
  scale_x_continuous(breaks = seq(2013, 2025, by = 1)) +
  # Adding a slight angle to the labels helps if they get crowded
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))
