# Cleaning up the global df from cpdb
# Just need to keep the necessary columns

library(dplyr)

cpdb_clean <- global_policy_df %>%
  select(policy_id, country_iso, policy_status, policy_objective, decision_date )


# Now let's classify either mitigation, adaptation, or both based on the policy_objective column. 
cpdb_clean <- cpdb_clean %>%
  mutate(
    policy_type = case_when(
      grepl("mitigation", policy_objective, ignore.case = TRUE) & 
        grepl("adaptation", policy_objective, ignore.case = TRUE) ~ "both",
      grepl("mitigation", policy_objective, ignore.case = TRUE) ~ "mitigation",
      grepl("adaptation", policy_objective, ignore.case = TRUE) ~ "adaptation",
      TRUE ~ "other"
    )
  )

# drop original policy_objective column
cpdb_clean <- cpdb_clean %>%
  select(-policy_objective)

# save cpdb_clean for later use
saveRDS(cpdb_clean, file = "02.data/data-preprocessed/cpdb_clean.rds")
