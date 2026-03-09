# I want to start small just to see what I can do with the data I currently have

library(ggplot2)
library(dplyr)
library(tidyr)

# First, I need to change the format of the data to get the cumulative number of policies adopted by each country over time.
policy_growth <- cpdb_master_df %>%
  # Turning decision_date into numeric for easier handling
  mutate(decision_date = as.numeric(decision_date)) %>% 
  # Filter for valid decision years
  filter(!is.na(decision_date)) %>%
  # Count new policies per country per year
  group_by(country_iso, decision_date) %>%
  summarise(new_policies = n(), .groups = 'drop') %>%
  # Now full_seq will work because decision_date is numeric
  complete(country_iso, decision_date = full_seq(decision_date, 1), fill = list(new_policies = 0)) %>%
  # Calculate cumulative sum
  group_by(country_iso) %>%
  mutate(cumulative_policies = cumsum(new_policies)) %>%
  ungroup()


# Create a single plot with all countries
Cumulative_pol_adoption <- ggplot(policy_growth, aes(x = decision_date, y = cumulative_policies, color = country_iso, group = country_iso)) +
  geom_line(size = 0.8, alpha = 0.7) +
  labs(
    title = "Evolution of Cumulative Climate Policy Adoption (Global)",
    x = "Year of Decision",
    y = "Total Cumulative Policies",
    color = "Country (ISO-3)"
  ) +
  theme_minimal() +
  # Adding a legend if the number of countries is small
  theme(legend.position = "right")
print(Cumulative_pol_adoption)

