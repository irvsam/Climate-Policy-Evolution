library(ggplot2)

# Heatmap of Average Stringency by Country and Sector (Level 2)
oecd_final_clean %>%
  filter(Level == "LEV2") %>%
  group_by(iso3, Sector, year) %>%
  summarise(avg_stringency = mean(stringency, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = Sector, fill = avg_stringency)) +
  geom_tile() +
  facet_wrap(~iso3) +
  scale_fill_viridis_c(option = "magma", name = "Ambition Score") +
  theme_minimal() +
  labs(title = "Climate Policy Ambition Trends (2012-2023)",
       subtitle = "Higher scores indicate more stringent policy frameworks",
       x = "Year", y = "Policy Sector")


ggplot(ndgain_clean, aes(x = year, y = score, color = iso3)) +
  geom_line(size = 1) +
  geom_point() +
  theme_minimal() +
  labs(title = "ND-GAIN Vulnerability Trends",
       subtitle = "Tracking progress across target 14 countries",
       y = "Vulnerability Score (Lower is better)",
       x = "Year")


# Now that we have the ndc text data we can actually see some promises vs actual measures being mapped

# Get average stringency from OECD data
oecd_summary <- oecd_final_clean %>%
  group_by(iso3) %>%
  summarise(avg_stringency = mean(stringency, na.rm = TRUE))

# Join them
comparison_df <- ndc_final %>%
  inner_join(oecd_summary, by = "iso3")

