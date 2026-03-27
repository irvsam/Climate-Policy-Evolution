# I now have the clean dataset ready to analyze the evolution of policies over time.

# Define adaptation-inclusive policies and calculate cumulative counts
adaptation_growth <- cpdb_final_clean %>%
  filter(!is.na(decision_date)) %>%
  # Flag anything that is 'adaptation' or 'both'
  mutate(has_adaptation = ifelse(policy_type %in% c("adaptation", "both"), 1, 0)) %>%
  group_by(decision_date) %>%
  summarise(yearly_count = sum(has_adaptation), .groups = 'drop') %>%
  arrange(decision_date) %>%
  mutate(cumulative_adaptation = cumsum(yearly_count))


# Do the same for Mitigation for a baseline comparison
mitigation_growth <- cpdb_final_clean %>%
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

cpdb_cumulative_adaptation_growth <- ggplot(adaptation_growth, aes(x = decision_date, y = cumulative_adaptation)) +
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

# Add lines for the important paris agreement dates: the agreement was adopted in 2015 and came into force in 2016. 
cpdb_cumulative_adaptation_growth <- cpdb_cumulative_adaptation_growth +
  geom_vline(xintercept = 2015, linetype = "dashed", color = "red", size = 0.8) +
  geom_vline(xintercept = 2016, linetype = "dashed", color = "blue", size = 0.8) +
  annotate("text", x = 2015, y = max(adaptation_growth$cumulative_adaptation) * 0.9, label = "Paris Agreement Adopted", angle = 90, vjust = -0.5, color = "red") +
  annotate("text", x = 2016, y = max(adaptation_growth$cumulative_adaptation) * 0.9, label = "Paris Agreement Signed", angle = 90, vjust = -0.5, color = "blue")


# See which countries have the most adaptation policies

# Calculate total unique adaptation-related policies per country (2013-2025)
country_totals <- cpdb_final_clean %>%
  filter(policy_type %in% c("adaptation", "both")) %>%
  group_by(country_iso) %>%
  summarise(total_policies = n_distinct(policy_id), .groups = 'drop') %>%
  arrange(desc(total_policies)) %>%
  # Create a rank to show the "tail" on the x-axis
  mutate(rank = row_number())



# Load ND-GAIN data (only have the 2023 index)

ndgain_data <- read_csv("02.data/data-raw/gain.csv") %>%
  # Select only the most recent year if the data is longitudinal
  # Usually ND-GAIN has columns like 'vulnerability_2022'
  select(country_iso = ISO3, vulnerability_index = '2023')

# Filter countries with > 3 policies and join
vulnerability_report <- country_totals %>%
  filter(total_policies > 3) %>%
  left_join(ndgain_data, by = "country_iso") %>%
  # Remove any rows where vulnerability index is missing
  filter(!is.na(vulnerability_index)) %>%
  arrange(desc(vulnerability_index)) # Sort by most vulnerable first

# Maybe it's better to instead compare their adaptation mix instead of absolute count of adaptation policies

# View the list
print(vulnerability_report)

# Compare the average nd gain amongst those with 3+ policies to those with 0-3
average_vulnerability <- country_totals %>%
  left_join(ndgain_data, by = "country_iso") %>%
  mutate(policy_group = ifelse(total_policies > 3, "3+ policies", "0-3 policies")) %>%
  group_by(policy_group) %>%
  summarise(average_vulnerability = mean(vulnerability_index, na.rm = TRUE), .groups = 'drop')

print(average_vulnerability)


# =============== Better way of doing things? ================

# Calculate the ratio of Adaptation vs. Mitigation per country
adaptation_mix <- cpdb_final_clean %>%
  filter(country_iso %in% TARGET_ISO3) %>%
  # Categorize each policy
  mutate(has_adaptation_focus = ifelse(policy_type %in% c("adaptation", "both"), 1, 0),
         is_purely_mitigation = ifelse(policy_type %in% c("mitigation"), 1, 0)) %>%
  group_by(country_iso) %>%
  summarise(
    total_count = n(),
    adapt_count = sum(has_adaptation_focus),
    mitig_count = sum(is_purely_mitigation),
    # The Ratio: What % of their total portfolio includes adaptation?
    adapt_ratio = (adapt_count / total_count) * 100
  ) %>%
  left_join(ndgain_data, by = "country_iso") %>%
  arrange(desc(adapt_ratio))


cpdb_adaptation_mix_plot <- ggplot(adaptation_mix, aes(x = reorder(country_iso, adapt_ratio), y = adapt_ratio, fill = vulnerability_index)) +
  geom_col() +
  coord_flip() +
  scale_fill_viridis_c(option = "plasma", name = "Vulnerability (ND-GAIN)") +
  labs(
    title = "Climate Policy Mix: Adaptation Priority",
    subtitle = "Percentage of total policy portfolio dedicated to Adaptation",
    x = "Country",
    y = "Adaptation Share of Portfolio (%)"
  ) +
  theme_minimal()

