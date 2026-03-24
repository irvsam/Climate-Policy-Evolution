
# Removing na values
oecd_final_clean <- oecd_final_clean %>%
  filter(!is.na(stringency))


# Add a note to the end of this graph about which countries are missing from this
stringency_plot_note <- "Note: Data for Rwanda and USA is missing."

# Heatmap of Average Stringency by Country and Sector (Level 2)
oecd_stringency_plot <- oecd_final_clean %>%
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
       x = "Year", y = "Policy Sector",
       caption = stringency_plot_note)




ndgain_vuln_score <- ggplot(ndgain_final_clean, aes(x = year, y = score, color = iso3)) +
  geom_line(size = 1) +
  geom_point() +
  theme_minimal() +
  labs(title = "ND-GAIN Vulnerability Trends",
       subtitle = "Tracking progress across target 12 countries",
       y = "Vulnerability Score (Lower is better)",
       x = "Year")

