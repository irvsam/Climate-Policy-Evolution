# First need to change ndc final into targeted ndc
ndc_targeted <- ndc_iges_final_clean %>%
  filter(iso3 %in% TARGET_ISO3)


adaptation_focus_df <- ndc_targeted %>%
  select(iso3, adapt_focus_score) %>%
  left_join(ndgain_final_clean %>% filter(year == 2023), by = "iso3") %>%
  # Adding a 'Need Category' for better coloring
  mutate(vulnerability_tier = case_when(
    score > 60 ~ "Low Vulnerability",
    score > 50 ~ "Moderate Vulnerability",
    TRUE ~ "High Vulnerability"
  ))

ndc_iges_adaptation_focus <- ggplot(adaptation_focus_df, aes(x = reorder(iso3, adapt_focus_score), y = adapt_focus_score, fill = vulnerability_tier)) +
  geom_bar(stat = "identity") +
  coord_flip() + # Flip for easier reading of country codes
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("High Vulnerability" = "#d35400", 
                               "Moderate Vulnerability" = "#f39c12", 
                               "Low Vulnerability" = "#2980b9")) +
  labs(
    title = "National Adaptation Focus in Climate Pledges",
    subtitle = "% of NDC Document dedicated to Adaptation vs. Vulnerability Level From NDC IGES Dataset",
    x = "Country",
    y = "Adaptation 'Mindshare' (Text Ratio)",
    fill = "Climate Need"
  ) +
  theme_minimal()


