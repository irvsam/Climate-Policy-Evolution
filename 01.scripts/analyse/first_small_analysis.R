
# ===================== Cumulative Policy Adoption Over Time =================================================================

# First, I need to change the format of the data to get the cumulative number of policies adopted by each country over time.

# Need to just take for our target countries
cpdb_final_clean_targeted <- cpdb_final_clean %>%
  filter(country_iso %in% TARGET_ISO3)


policy_growth <- cpdb_final_clean_targeted %>%
  # Turning decision_date into numeric for easier handling
  mutate(decision_date = as.numeric(decision_date)) %>% 
  # Filter for valid decision years
  filter(!is.na(decision_date)) %>%
  # Count new policies per country per year
  group_by(country_iso, decision_date) %>%
  summarise(new_policies = n(), .groups = 'drop') %>%
  # Ensure every year from START_YEAR to END_YEAR is represented for each country
  complete(country_iso, decision_date = full_seq(decision_date, 1), fill = list(new_policies = 0)) %>%
  # Calculate cumulative sum
  group_by(country_iso) %>%
  mutate(cumulative_policies = cumsum(new_policies)) %>%
  ungroup()


# Create a single plot with all countries
cpdb_cumulative_pol_adoption <- ggplot(policy_growth, aes(x = decision_date, y = cumulative_policies, color = country_iso, group = country_iso)) +
  geom_line(size = 0.8, alpha = 0.7) +
  labs(
    title = "Evolution of Cumulative Climate Policy Adoption",
    subtitle = "Data from CPDB for Target Countries",
    x = "Year of Decision",
    y = "Total Cumulative Policies",
    color = "Country (ISO-3)"
  ) +
  theme_minimal() +
  # Adding a legend if the number of countries is small
  theme(legend.position = "right")

# Lets add a line around when the paris agreement came into effect
cpdb_cumulative_pol_adoption <- cpdb_cumulative_pol_adoption +
  geom_vline(xintercept = 2015, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2015, y = max(policy_growth$cumulative_policies) * 0.9, label = "Paris Agreement (2015)", angle = 90, vjust = -0.5, size = 3)
# Country names could actually be printed at the end of their lines so we have a clear leaderboard
cpdb_cumulative_pol_adoption <- cpdb_cumulative_pol_adoption +
  geom_text(data = policy_growth %>% group_by(country_iso) %>% filter(decision_date == max(decision_date)), 
            aes(label = country_iso), 
            # Position the labels slightly to the right of the last point
            hjust = -0.1, 
            # Vertically center the labels with respect to the last point
            vjust = 0.5, 
            # Use a smaller font size to avoid overlap if there are many countries
            size = 2, 
            show.legend = FALSE)



# How many total policies were added in 2015?
policy_growth %>%
  filter(decision_date >= 2015 & decision_date <= 2016) %>%
  summarise(total_new_policies = sum(new_policies))


# And in 2012?
policy_growth %>%
  filter(decision_date >= 2012 & decision_date <= 2013) %>%
  summarise(total_new_policies = sum(new_policies))


# What is the global evolution of climate policies titled adaptation or both?
global_adaptation_growth <- cpdb_final_clean %>%
  # Filter for adaptation-relevant documents globally
  filter(policy_type %in% c("adaptation", "both")) %>%
  mutate(decision_date = as.numeric(decision_date)) %>%
  filter(!is.na(decision_date) & decision_date >= START_YEAR) %>%
  
  # Aggregate counts by year
  group_by(decision_date) %>%
  summarise(new_adaptation_policies = n(), .groups = 'drop') %>%
  
  # Calculate Cumulative Global Sum
  complete(decision_date = full_seq(decision_date, 1), fill = list(new_adaptation_policies = 0)) %>%
  mutate(cumulative_adaptation = cumsum(new_adaptation_policies))

# Plot Global Trend
global_adaptation_growth_plot <- ggplot(global_adaptation_growth, aes(x = decision_date, y = cumulative_adaptation)) +
  
  geom_line(color = "seagreen", size = 1) +
  geom_vline(xintercept = 2015, linetype = "dashed", color = "red") +
  annotate("text", x = 2015, y = max(global_adaptation_growth$cumulative_adaptation)*0.8, 
           label = "Paris Agreement", angle = 90, vjust = -0.5) +
  labs(
    title = "Global Cumulative Growth of Adaptation-Relevant Policies",
    x = "Year",
    y = "Total Cumulative Global Policies"
  ) +
  theme_minimal()

# How many new adaptation policies were implemented in 2015 globally?
global_adaptation_growth %>%
  filter(decision_date >= 2014 & decision_date <= 2016) %>%
  summarise(new_adaptation_policies_2015 = sum(new_adaptation_policies))

