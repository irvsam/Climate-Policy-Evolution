# ==============================================================================
# Project: Climate Policy Portfolio Analysis (Paris Agreement Shift)
# Author: Sammy Irving
# Purpose: Orchestration script to run the full pipeline.
# ==============================================================================

# Global Toggles
FORCE_RECLEAN <- FALSE # Set to TRUE if scripts have been edited

# Setup & Global Variables -------------------------------------------------

# Code to install packages if they do not exist
required_packages <- c(
  "dplyr", "httr2", "readr", "reticulate", "purrr", "stringr", 
  "tidyr", "OECD", "countrycode", "readxl", "janitor", 
  "ggplot2", "tidytext", "ggrepel", "pdftools", "httr"
)

# Only install if it isnt already installed
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {
  install.packages(new_packages)
}



# Load all required libraries
for (pkg in required_packages) {
  library(pkg, character.only = TRUE)
}

# Countries and years
TARGET_ISO3 <- c("CAN", "DEU", "JPN", "IND", "ZAF", "DNK", "GBR", "CHL", "COL", "USA", "SAU", "RWA")
START_YEAR <- 2012
END_YEAR <- 2025

# Create directory structure if missing
if (!dir.exists("02.data/data-raw")) dir.create("02.data/data-raw", recursive = TRUE)
if (!dir.exists("02.data/data-preprocessed")) dir.create("02.data/data-preprocessed")

# Data Collection Logic ----------------------------------------------------

# Online databases

url_ndcs_index <- "https://raw.githubusercontent.com/openclimatedata/ndcs/main/data/ndcs.csv"

# Download function
smart_download <- function(url, dest) {
  if (!file.exists(dest)) {
    message("Downloading: ", dest)
    download.file(url, dest, mode = "wb")
  } else {
    message("File already exists: ", dest)
  }
}
smart_download(url_ndcs_index, "02.data/data-raw/ndcs.csv")

# --- OECD CAPMF Data ---
if (!file.exists("02.data/data-raw/oecd_raw.rds")| FORCE_RECLEAN) {
  message("--- Fetching OECD CAPMF from API ---")
  source("01.scripts/collect/API_Connections.R") 
  saveRDS(oecd_df_collected, "02.data/data-raw/oecd_raw.rds")
  oecd_raw <- oecd_df_collected # Load into memory for current session
} else {
  message("--- Loading OECD from local RDS ---")
  oecd_raw <- readRDS("02.data/data-raw/oecd_raw.rds")
}

# --- CPDB Data ---
if (!file.exists("02.data/data-raw/cpdb_raw.rds")| FORCE_RECLEAN) {
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

if (!file.exists(oecd_clean_path)| FORCE_RECLEAN) {
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

if (!file.exists(cpdb_clean_path)| FORCE_RECLEAN) {
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

if (!file.exists(ndgain_clean_path)| FORCE_RECLEAN) {
  message("Clean ndgain data not found. Processing raw data...")
  
  if (!exists("ndgain_raw")) ndgain_raw <- read_csv("02.data/data-raw/gain.csv") 
  
  source("01.scripts/clean/ndgain_clean.R")
  
  saveRDS(ndgain_final_clean, ndgain_clean_path)
  message("Saved: ndgain_clean.rds")
} else {
  message("Loading pre-processed ndgain data...")
  ndgain_final_clean <- readRDS(ndgain_clean_path)
}


# --- NDC CLEANING ---
ndc_clean_path <- "02.data/data-preprocessed/ndc_clean.rds"
ndc_text_path  <- "02.data/data-preprocessed/ndc_extracted_text.rds"

if (!file.exists(ndc_clean_path)| FORCE_RECLEAN) { # If the ndc clean data doesnt exist nor will the extracted text list
  message("Clean ndc data not found. Processing raw data...")
  
  if (!exists("ndc_raw")) ndc_raw <- read_excel("02.data/data-raw/IGESNDC.xlsx", 
                                                      sheet = "NDC MASTER SHEET", 
                                                      skip = 4, 
                                                      col_names = FALSE)
  
  source("01.scripts/clean/ndc_clean.R")
  saveRDS(ndc_iges_final_clean, ndc_clean_path)
  
  # Also need to save the extracted text list for the NDC scoring script
  saveRDS(ndc_extracted_text_list, ndc_text_path)
  message("Saved: ndc_clean.rds and ndc_extracted_text.rds")
} else {
  message("Loading pre-processed ndc data...")
  ndc_iges_final_clean <- readRDS(ndc_clean_path)
  ndc_extracted_text_list <- readRDS(ndc_text_path)
}


# Analysis and Visualization ----------------------------------------------

# Creating cumulative policy adoption graph
source("01.scripts/analyse/first_small_analysis.R")

# stringency plot and vulnerability score
source("01.scripts/analyse/stringency_evolution.R")

source("01.scripts/analyse/cpdb_evolution.R")

source("01.scripts/analyse/ndc_scoring.R")

source("01.scripts/analyse/ndc_adapt_focus.R")


# ==============================================================================
# Housekeeping & Environment Cleanup
# ==============================================================================
message("--- Cleaning up Environment ---")
message("If you are wanting to run any sub scripts then remove this section")


# Define objects to keep
objects_to_keep <- c(
  "oecd_final_clean", 
  "cpdb_final_clean", 
  "ndgain_final_clean", 
  "ndc_iges_final_clean",
  "ndc_extracted_text_list",
  "TARGET_ISO3", 
  "START_YEAR", 
  "END_YEAR",
  "cpdb_cumulative_pol_adoption",
  "oecd_stringency_plot",
  "ndgain_vuln_score",
  "cpdb_cumulative_adaptation_growth",
  "cpdb_adaptation_mix_plot",
  "ndc_adaptation_leaderboard",
  "ndc_ambition_vs_focus",
  "ndc_adaptation_focus"
  )

# Remove everything else
rm(list = setdiff(ls(), objects_to_keep))

# Run garbage collection to free up system RAM
gc()

message("Cleanup complete. Only analysis-ready dataframes remain in memory.")

