#####################################################################
# Example dataset                                                   #
# Based on National Health and Nutrition Examination Study (NHANES) #
# To reproduce, download the file "DEMO_I.XPT" from:                #
# https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_I.htm             #
#####################################################################

require(pacman)
# We load the SASxport::foreign library to import SAS-format data
p_load(SASxport, foreign, dplyr)

DEMO <- read.xport("data/DEMO_I.XPT") %>%
  janitor::clean_names()
DEMO %>%
  glimpse()

# Factor coding for meaningful levels
nhanes_15_16 <- DEMO %>%
  mutate(PSU = sdmvpsu,
         weights = wtint2yr,
         strata = sdmvstra,
         gender = factor(riagendr,
                         levels = c(1, 2),
                         labels = c("Male", "Female")),
         age = ridageyr,
         birth_country = factor(dmdborn4,
                                levels = c(1, 2, 77, 99),
                                labels = c("US", "Other", "Refused", "Don't know")),
         marital_status = factor(dmdhrmar,
                                 levels = c(1, 2, 3, 4, 5, 6, 77, 99),
                                 labels = c("Married", "Widowed", "Divorced", "Separated",
                                            "Never married", "Living with partner",
                                            "Refused", "Don't know")),
         interview_lang = factor(fialang,
                                 labels = c("English", "Spanish")),
         edu_level = factor(dmdhredu,
                            levels = c(1, 2, 3, 4, 5, 7, 9),
                            labels = c("Less Than 9th Grade", "9-11th Grade", "High School",
                                       "College degree", "College graduate or above", "Refused",
                                       "Don't know")),
         household_size = dmdhhsiz,
         family_size = dmdfmsiz,
         annual_household_income = indhhin2,
         annual_family_income = indfmin2,
         .keep = "none")

# Have a look at results
glimpse(nhanes_15_16)
table(nhanes_15_16$edu_level)
cumsum(table(nhanes_15_16$edu_level))
nhanes_15_16 %>%
  count(strata)

# Let us assess NAs
# summary(nhanes)
nhanes_15_16 %>% summarise(across(everything(), ~sum(is.na(.x))))
# We remove marital status because it has too much missing data and rows
# with missing data in other variables
nhanes_15_16 <- na.omit(nhanes_15_16)
save(nhanes_15_16, file = "data/nhanes_15_16.RData")
