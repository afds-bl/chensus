#' National Health and Nutrition Examination Survey (NHANES)
#'
#' Demographic survey data from NHANES 2015 to 2016, with data on 9971
#' participants, including sampling weights.
#'
#' @format A data frame with 9971 rows and 13 variables:
#' \describe{
#'   \item{PSU}{SDMVPSU - Masked variance pseudo-PSU}
#'   \item{weights}{WTINT2YR - Full sample 2 year interview weight}
#'   \item{strata}{SDMVSTRA - Masked variance pseudo-stratum}
#'   \item{gender}{RIAGENDR - Gender}
#'   \item{age}{RIDAGEYR - Age in years at screening }
#'   \item{birth_country}{DMDBORN4 - Country of birth}
#'   \item{marital_status}{DMDMARTL - Marital status}
#'   \item{interview_lang}{SIALANG - Language of interview}
#'   \item{edu_level}{DMDHREDU - Household reference person's education level}
#'   \item{household_size}{DMDHHSIZ - Total number of people in the Household}
#'   \item{family_size}{DMDFMSIZ - Total number of people in the Family}
#'   \item{annual_household_income}{INDHHIN2 - Annual household income}
#'   \item{annual_family_income}{INDFMIN2 - Annual family income}
#' }
#' @docType data
#'
#' @note
#' The data sets provided in this package are derived from the NHANES database and have been adapted for educational purposes. As such, they are NOT suitable for use as a research database.
#' For research purposes, you should download original data files from the NHANES website and follow the analysis instructions given there.
#'
#' @keywords datasets
#'
#' @references
#' \href{https://wwwn.cdc.gov/nchs/nhanes/}{CDC}
#'
#' @source \href{https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=2015}{NHANES 2015-2016}
#'
#' @examples
#' library(dplyr)
#' glimpse(nhanes)
#' nhanes |> dplyr::count(edu_level)
"nhanes"
