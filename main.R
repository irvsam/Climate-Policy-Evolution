# main.R

# Define file paths
oecd_path <- "02.data/data-preprocessed/oecd_capmf_data.csv"
cpdb_path <- "02.data/data-preprocessed/cpdb_data.csv"

# ========================= CREATE DATA DIRECTORY IF NOT EXISTS =========================

# =============================== OECD CAPMF DATA ===============================
if (!file.exists(oecd_path)) {
  message("OECD data not found locally. Fetching from API...")
  
  
  source("01.scripts/loading data/API_Connections.R")
  
  write_csv(oecd_df, oecd_path)
} else {
  message("Loading OECD data from local cache.")
  oecd_df <- read_csv(oecd_path, show_col_types = FALSE)
}

# =============================== CPDB DATA =====================================
if (!file.exists(cpdb_path)) {
  message("CPDB data not found locally. Fetching from API (this may take a while)...")
  
  source("01.scripts/loading data/Other_data.R")
  
  write_csv(cpdb_master_df, cpdb_path)
} else {
  message("Loading CPDB data from local cache.")
  cpdb_master_df <- read_csv(cpdb_path, show_col_types = FALSE)
}



# =============================== DATA CLEANING ==============================


# Do some initial analysis
source("01.scripts/analysis/first_small_analysis.R")