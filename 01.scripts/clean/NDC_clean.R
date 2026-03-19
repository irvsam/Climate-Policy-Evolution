library(readxl)
library(dplyr)
library(tidyr)
library(janitor)

path <- "02.data/data-raw/IGESNDC.xlsx" 

# Load the data 
ndc_raw <- read_excel(path, sheet = "NDC MASTER SHEET") %>% 
  clean_names()

# Quick check of available columns
colnames(ndc_raw)

