# ==============================================================================
# Project: Climate Policy Portfolio Analysis (Paris Agreement Shift)
# Author: Sammy Irving
# Purpose: Orchestration script to run the full pipeline.
# ==============================================================================

# Setup & Global Variables -------------------------------------------------

# Load Libraries -----------------------------------------------------------
library(dplyr)
library(httr2)
library(readr)
library(reticulate)
library(purrr)


# Countries and years
TARGET_ISO3 <- c("CAN", "DEU", "JPN", "IND", "ZAF", "DNK", "GBR", "CHL", "COL", "USA", "SAU", "RWA")
START_YEAR <- 2012
END_YEAR <- 2025

# Create directory structure if missing
if (!dir.exists("02.data/data-raw")) dir.create("02.data/data-raw", recursive = TRUE)
if (!dir.exists("02.data/data-preprocessed")) dir.create("02.data/data-preprocessed")

# Data Collection Logic ----------------------------------------------------
# --- OECD CAPMF Data ---
if (!file.exists("02.data/data-raw/oecd_raw.rds")) {
  message("--- Fetching OECD CAPMF from API ---")
  source("01.scripts/collect/API_Connections.R") 
  saveRDS(oecd_df_collected, "02.data/data-raw/oecd_raw.rds")
  oecd_raw <- oecd_df_collected # Load into memory for current session
} else {
  message("--- Loading OECD from local RDS ---")
  oecd_raw <- readRDS("02.data/data-raw/oecd_raw.rds")
}

# --- CPDB Data ---
if (!file.exists("02.data/data-raw/cpdb_raw.rds")) {
  message("--- Fetching CPDB from API ---")
  source("01.scripts/collect/API_Connections.R") 
  saveRDS(cpdb_df_collected, "02.data/data-raw/cpdb_raw.rds")
  cpdb_raw <- cpdb_df_collected # Load into memory for current session
} else {
  message("--- Loading CPDB from local RDS ---")
  cpdb_raw <- readRDS("02.data/data-raw/cpdb_raw.rds")
}

# Data Cleaning & Integration ----------------------------------------------
message("--- Starting Data Cleaning & Pre-processing ---")


message("--- Main Pipeline Finished ---")