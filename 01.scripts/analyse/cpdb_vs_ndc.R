# Filter cpdb to only include our target countries
cpdb_final_clean_targeted <- cpdb_final_clean %>%
  filter(country_iso %in% TARGET_ISO3)

# Get the adaptation focus of each country from cpdb
cpdb_adaptation_focus <- adaptation_mix %>%
  select(country_iso, adapt_ratio) %>%
  rename(iso3 = country_iso, cpdb_adapt_focus = adapt_ratio)

# Get the adaptation focus of each country from NDCs

ndc_adaptation_focus <- focus_score %>%
  select(iso3, relative_adapt_focus)

# Join the two datasets to compare
comparison_df <- cpdb_adaptation_focus %>%
  left_join(ndc_adaptation_focus, by = "iso3")

# The numbers need o be scaled to both be a percent
comparison_df <- comparison_df %>%
  mutate(relative_adapt_focus = relative_adapt_focus * 100) 

# Rename the columns
comparison_df <- comparison_df %>%
  rename(
    cpdb_adaptation_focus = cpdb_adapt_focus,
    ndc_adaptation_focus = relative_adapt_focus
  )

ndc_cpdb_comparison_df <- comparison_df

# Format the dataframe for the "Audit"
table_to_save <- ndc_cpdb_comparison_df %>%
  mutate(
    cpdb_mix = round(cpdb_adaptation_focus, 1),
    ndc_focus = round(ndc_adaptation_focus, 1),
    gap = round(ndc_focus - cpdb_mix, 1)
  ) %>%
  select(iso3, cpdb_mix, ndc_focus, gap) %>%
  arrange(desc(ndc_focus))

#Create the styled table object
ndc_cpdb_comparison_table <- table_to_save %>%
  gt() %>%
  tab_header(
    title = md("**Comparing Policy Implementation (CPDB) to Strategic Focus (NDC)**"),
  ) %>%
  cols_label(
    iso3 = "ISO-3",
    cpdb_mix = "CPDB Mix (%)",
    ndc_focus = "NDC Focus (%)",
    gap = "The Gap (diff)"
  ) %>%
  # Add a color scale to the 'Gap' column to highlight the Responsibility Gap
  data_color(
    columns = gap,
    colors = scales::col_numeric(
      palette = c("white", "#d35400"),
      domain = c(0, 60)
    )
  ) %>%
  tab_options(table.width = px(400))


