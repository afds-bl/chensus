# Download the raw Nhanes 2015-2016 data from https://wwwn.cdc.gov/nchs/nhanes/search/DataPage.aspx?Component=Demographics&Cycle=2015-2016
#  Latest download 28/05/2025

if (!requireNamespace("haven", quietly = TRUE)) {
  stop("Package 'haven' needed to read the .xpt file. Please install it.")
}

library(haven)
library(dplyr)
library(readr)
library(forcats)

# Read raw data in  SAS transport format (.xpt)
raw_nhanes <- read_xpt(here::here("data-raw", "DEMO_I.xpt"))

# Read coding files
code_marital_status <- read_tsv(here::here("data-raw", "code_marital_status.tsv"))
code_edu_level <- read_tsv(here::here("data-raw", "code_edu_level.tsv"))

group_vars <- 

nhanes <- raw_nhanes |>
  select(
    PSU = SDMVPSU,
    weights = WTINT2YR,
    strata = SDMVSTRA,
    gender = RIAGENDR,
    age = RIDAGEYR,
    birth_country = DMDBORN4,
    marital_status = DMDMARTL,
    interview_lang = SIALANG,
    edu_level = DMDHREDU,
    household_size = DMDHHSIZ,
    family_size = DMDFMSIZ,
    annual_household_income = INDHHIN2,
    annual_family_income = INDFMIN2
  ) |>
  mutate(
    gender = factor(gender, levels = 1:2, labels = c("Male", "Female")),
    birth_country = factor(birth_country, levels = 1:2, labels = c("US", "Other")),
    marital_status = factor(marital_status, levels = code_marital_status$Code, labels = code_marital_status$Value),
    interview_lang = factor(interview_lang, levels = 1:2, labels = c("English", "Spanish")),
    edu_level = factor(edu_level, levels = code_edu_level$Code, labels = code_edu_level$Value)
  ) |> 
  mutate(across(where(is.factor), \(v) fct_na_value_to_level(v, "Missing"))) |> 
  mutate(across(where(is.factor), \(v) fct_infreq(v)))

usethis::use_data(nhanes, overwrite = TRUE)
