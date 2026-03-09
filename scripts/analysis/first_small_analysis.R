# I want to start small just to see what I can do with the data I currently have

library(ggplot2)
library(dplyr)
library(tidyr)


# Summarize CPDB data by year and country
trend_data <- cpdb_master_df %>%
  group_by(country_iso, query_year) %>%
  summarise(policy_count = n(), .groups = 'drop')

# Plot
ggplot(trend_data, aes(x = query_year, y = policy_count, color = country_iso)) +
  geom_line(size = 1) +
  geom_point() +
  theme_minimal() +
  labs(title = "Climate Policy Adoption Trend (2015-2026)",
       x = "Year",
       y = "Number of Policies 'In Force'",
       color = "Country")
