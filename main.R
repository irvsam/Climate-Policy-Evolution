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
library(stringr)
library(tidyr)
library(OECD)
library(countrycode)
library(readxl)
library(janitor)



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
# --- OECD CLEANING ---
oecd_clean_path <- "02.data/data-preprocessed/oecd_clean.rds"

if (!file.exists(oecd_clean_path)) {
  message("Clean OECD data not found. Processing raw data...")
  
  # Ensure raw data is in memory
  if (!exists("oecd_raw")) oecd_raw <- readRDS("02.data/data-raw/oecd_raw.rds")
  
  # Run the cleaning script
  source("01.scripts/clean/oecd_clean.R") 
  
  # Save the result produced by the script
  saveRDS(oecd_final_clean, oecd_clean_path)
  message("Saved: oecd_clean.rds")
} else {
  message("Loading pre-processed OECD data...")
  oecd_final_clean <- readRDS(oecd_clean_path)
}

# --- CPDB CLEANING ---
cpdb_clean_path <- "02.data/data-preprocessed/cpdb_clean.rds"

if (!file.exists(cpdb_clean_path)) {
  message("Clean CPDB data not found. Processing raw data...")
  
  if (!exists("cpdb_raw")) cpdb_raw <- readRDS("02.data/data-raw/cpdb_raw.rds")
  
  source("01.scripts/clean/cpdb_clean.R")
  
  saveRDS(cpdb_final_clean, cpdb_clean_path)
  message("Saved: cpdb_clean.rds")
} else {
  message("Loading pre-processed CPDB data...")
  cpdb_final_clean <- readRDS(cpdb_clean_path)
}

message("--- Main Pipeline Finished ---")


# --- NDGAIN CLEANING ---
ndgain_clean_path <- "02.data/data-preprocessed/ndgain_clean.rds"

if (!file.exists(ndgain_clean_path)) {
  message("Clean ndgain data not found. Processing raw data...")
  
  if (!exists("ndgain_raw")) ndgain_raw <- read_csv("02.data/data-raw/gain.csv") 
  
  source("01.scripts/clean/ndgain_clean.R")
  
  saveRDS(ndgain_final_clean, ndgain_clean_path)
  message("Saved: ndgain_clean.rds")
} else {
  message("Loading pre-processed ndgain data...")
  ndgain_final_clean <- read_csv(ndgain_clean_path)
}


# --- NDC CLEANING ---
ndc_clean_path <- "02.data/data-preprocessed/ndc_clean.rds"

if (!file.exists(ndc_clean_path)) {
  message("Clean ndc data not found. Processing raw data...")
  
  if (!exists("ndc_raw")) ndc_raw <- read_excel("02.data/data-raw/IGESNDC.xlsx", 
                                                      sheet = "NDC MASTER SHEET", 
                                                      skip = 4, 
                                                      col_names = FALSE)
  
  source("01.scripts/clean/ndc_clean.R")
  
  saveRDS(ndc_final_clean, ndc_clean_path)
  message("Saved: ndc_clean.rds")
} else {
  message("Loading pre-processed ndc data...")
  ndc_final_clean <- read_csv(ndc_clean_path)
}

