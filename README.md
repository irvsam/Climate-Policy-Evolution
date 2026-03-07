# Climate Policy Evolution

Climate Resilience: Comparing the Evolution of Integrated Climate Policies in Rwanda and G20 Nations (2015–2022)

This repository contains the code for a small data mining project developed as part of the course:


**Data Access and Data Mining for Social Sciences**

University of Lucerne

- Student Name: Samantha Irving
- Course: Data Mining for the Social Sciences using R
- Term: Spring 2026

## Project Goal

The goal of this project is to collect and analyze data from an online source (API or web scraping) in order to answer a research question relevant to political or social science.

The project should demonstrate:

- Identification of a suitable data source
- Automated data collection (API or scraping)
- Data cleaning and preparation
- Reproducible analysis


## Research Question

*Have climate policy portfolios shifted from mitigation toward adaptation after the Paris Agreement, and does this shift differ between Global North and Global South countries?*


## Data Source

CPDC (Climate Policy Database) is a comprehensive database of climate policies worldwide, covering over 1,000 policies across 196 countries from 1990 to 2022.
- API: 
- Database: https://climatepolicydatabase.org/
- Access Methods: API access via Python package
- Problem? It is a python package, but we can use reticulate in R to access it. Alternatively, we can download the dataset and process it in R.

OECD CAPMF (Climate Action) provides data on climate action policies and measures implemented by OECD countries, including information on policy types, sectors, and implementation status.
- API: 
- Data Explorer: https://data-explorer.oecd.org/vis?lc=en&fs[0]=Topic%2C1%7CEnvironment%23ENV%23%7CEnvironmental%20policy%23ENV_POL%23&pg=0&fc=Topic&bp=true&snb=10&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_CAPMF%40DF_CAPMF&df[ag]=OECD.ENV.EPI&df[vs]=1.0&pd=2018%2C&dq=AUS.A.POL_STRINGENCY.LEV1_SEC%2BLEV2_SEC_E_MBI%2BLEV3_ETS_E%2BLEV4_ETS_E_PR%2BLEV4_ETS_E_GHG%2BLEV3_CARBONTAX_E%2BLEV3_FFS_E%2BLEV3_EXCISETAX_E%2BLEV3_FIT%2BLEV3_AUCTION%2BLEV3_RECS%2BLEV2_SEC_E_NMBI%2BLEV2_SEC_I_MBI%2BLEV2_SEC_I_NMBI%2BLEV2_SEC_B_MBI%2BLEV2_SEC_B_NMBI%2BLEV2_SEC_T_MBI%2BLEV2_SEC_T_NMBI%2BLEV1_CROSS_SEC%2BLEV1_INT.0_TO_10%2BPL&ly[cl]=TIME_PERIOD&to[TIME_PERIOD]=false
- Access Methods: API access via R package
- Limitations: OECD CAPMF only covers OECD countries (Not Rwanda), while CPDC includes global coverage. CPDC may have more detailed policy information, but OECD CAPMF provides standardized indicators for comparison.

ND GAIN (Notre Dame Global Adaptation Initiative) provides data on countries' vulnerability and readiness to adapt to climate change, including indicators on exposure, sensitivity, and adaptive capacity.
- API: there is no API, but data can be downloaded as CSV
- Link: https://gain.nd.edu/our-work/country-index/
- Access Methods: Download CSV and process in R

## Repository Structure

- scripts/     scripts used to collect/process data
- data/     output datasets (not tracked/pushed by git)
- README.md   project description
- report/     final report and visualizations
- output/   final outputs (e.g., tables, figures)



## Reproducibility

To reproduce this project:

1. Clone the repository
2. Install required R packages
3. Run the scripts in the `script/` folder

All data should be generated automatically by the scripts.


## Good Practices

Please follow these guidelines:

- Do **not upload raw datasets** to GitHub.
- Store **API keys outside the repository** (e.g., environment variables).
- Write scripts that run **from start to finish**.
- Commit your work **frequently**.
- Use **clear commit messages**.

Example commit messages:
added API request
cleaned dataset structure
added visualization
fixed JSON parsing


## Notes

Large datasets should not be pushed to GitHub.  
If necessary, provide instructions for downloading the data instead.
