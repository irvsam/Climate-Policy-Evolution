# main.R

# Define file paths
oecd_path <- "02.data/data-raw/oecd_raw.rds"
cpdb_path <- "02.data/data-raw/cpdb_raw.rds"

# ========================= DATA COLLECTION =========================

# =============================== OECD CAPMF DATA ===============================
# Check if RAW data exists
if (!file.exists("02.data/data-raw/oecd_raw.rds")) {
  message("Fetching from API...")
  source("01.scripts/collect/API_Connections.R") 
  saveRDS(cpdb_master_df, "02.data/data-raw/oecd_raw.rds") # Saving as rds for better performance and to preserve data types
} else {
  message("Loading from memory...")
  cpdb_master_df <- readRDS("02.data/data-raw/oecd_raw.rds")
}

# =============================== CPDB DATA =====================================
# Check if RAW data exists
if (!file.exists("02.data/data-raw/cpdb_raw.rds")) {
  message("Fetching from API...")
  source("01.scripts/collect/API_Connections.R") 
  saveRDS(cpdb_master_df, "02.data/data-raw/cpdb_raw.rds") # Saving as rds for better performance and to preserve data types
} else {
  message("Loading from memory...")
  cpdb_master_df <- readRDS("02.data/data-raw/cpdb_raw.rds")
}

# =============================== DATA CLEANING ==============================
