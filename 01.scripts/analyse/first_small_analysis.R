# I want to start small just to see what I can do with the data I currently have

library(ggplot2)
library(dplyr)
library(tidyr)

# ===================== Cumulative Policy Adoption Over Time =================================================================

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

# Save this intermediate data frame for later use
write.csv(policy_growth, "02.data/data-preprocessed/policy_growth_data.csv", row.names = FALSE)

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



# Save the plot
todays_date <- Sys.Date()
date_formatted <- format(todays_date, "%Y-%m-%d")
filename <- paste0("cumulative_policy_adoption_", todays_date, ".png")
folder_path <- paste0("03.output/", filename)
ggsave(folder_path, plot = Cumulative_pol_adoption, width = 10, height = 6, dpi = 300)

# ==================================== Policy Objectives ====================================================================================

# Now I want to see the number of mitigation vs adaptation strategies adopted per country per year (not time series)
# The policy_objective variable has the information about whether a policy is mitigation or adaptation, so I can use that to create a new data frame with the counts of each type of policy per country per year.
# I just want to list the different possibilities we have in this variable first
unique(cpdb_master_df$policy_objective)

library(stringr)

# Expanding the objective column
long_objectives <- cpdb_master_df %>%
  # Split strings by comma and space, then unnest them into new rows
  separate_rows(policy_objective, sep = ",\\s*") %>%
  mutate(policy_objective = trimws(policy_objective)) # Ensure no trailing spaces

# Filter for adaptation and aggregate by year and country
adaptation_data <- long_objectives %>%
  filter(policy_objective == "Adaptation") %>%
  mutate(decision_date = as.numeric(decision_date)) %>%
  filter(!is.na(decision_date)) %>%
  group_by(country_iso, decision_date) %>%
  summarise(adaptation_count = n(), .groups = 'drop')

mitigation_data <- long_objectives %>%
  filter(policy_objective == "Mitigation") %>%
  mutate(decision_date = as.numeric(decision_date)) %>%
  filter(!is.na(decision_date)) %>%
  group_by(country_iso, decision_date) %>%
  summarise(mitigation_count = n(), .groups = 'drop')


# Combine the objectives into one cleaned, long-format dataframe
objective_growth <- long_objectives %>%
  mutate(decision_date = as.numeric(decision_date)) %>%
  filter(!is.na(decision_date), policy_objective %in% c("Mitigation", "Adaptation")) %>%
  group_by(country_iso, policy_objective, decision_date) %>%
  summarise(new_policies = n(), .groups = 'drop') %>%
  # Ensure every year is present for every combination of country and objective
  complete(nesting(country_iso, policy_objective), 
           decision_date = full_seq(decision_date, 1), 
           fill = list(new_policies = 0)) %>%
  group_by(country_iso, policy_objective) %>%
  mutate(cumulative_policies = cumsum(new_policies)) %>%
  ungroup()


# Create the comparison plot
comparison_plot <- ggplot(objective_growth, aes(x = decision_date, y = cumulative_policies, color = policy_objective)) +
  geom_line(size = 0.8) +
  facet_wrap(~country_iso, scales = "free_y") +
  labs(
    title = "Comparison of Mitigation vs. Adaptation Policy Adoption",
    x = "Year",
    y = "Cumulative Policies",
    color = "Objective Type"
  ) +
  theme_minimal()

print(comparison_plot)


# I just want a bar graph showing the total number of mitigation vs adaptation policies adopted by each country, without the time series aspect
total_objectives <- long_objectives %>%
  filter(policy_objective %in% c("Mitigation", "Adaptation")) %>%
  group_by(country_iso, policy_objective) %>%
  summarise(total_policies = n(), .groups = 'drop')


# Create the bar graph
bar_graph <- ggplot(total_objectives, aes(x = country_iso, y = total_policies, fill = policy_objective)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Total Number of Mitigation vs. Adaptation Policies by Country",
    x = "Country (ISO-3)",
    y = "Total Policies",
    fill = "Objective Type"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(bar_graph)
                                          

