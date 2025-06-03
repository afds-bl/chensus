#' Summarise Structural Survey Data by Group
#'
#' \code{se_summarise()} stratifies and summarises the number of observations and
#' estimated populations in structural surveys provided by the FSO.

#' \code{se_summarise()} calculates group-wise survey statistics, augmenting the input data with columns for the number of true occurrences and estimated population per group.
#' 
#' @param data A tibble or a data frame.
#' @param weight Unquoted name of column containing the survey
#' weights.
#' @param ... One or more unquoted grouping variables (e.g., `strata`, `gender`). These define the groups for summarisation.
#' @param mh_col Character string, desired column name of number of true occurrences per group. Default is "mh".
#' @param Nh_col Character string, desired column name of estimated population per group. Default is "Nh".
#'
#' @returns
#' A tibble: the input \code{data} augmented with new columns \code{mh_col} and \code{Nhcol} (or their specified names).
#' 
#' @examples
#' # One stratum variable
#' library(dplyr)
#' se_summarise(nhanes, weight = weights, strata) |>
#'   glimpse()
#' # Two grouping variables
#' se_summarise(nhanes,
#'   weight = weights, 
#'   mh_col = "mhc", 
#'   Nh_col = "Nhc", 
#'   strata, gender
#' )
#'
#' @importFrom rlang enquo enquos
#' @import dplyr
#'
#' @export

se_summarise <- function(data, weight, ..., mh_col = "mh", Nh_col = "Nh") {
  weight_quo <- enquo(weight)
  group_quos <- enquos(...)
  
  data |>
    group_by(!!!group_quos) |>
    add_count(name = mh_col) |>
    add_count(wt = !!weight_quo, name = Nh_col) |>
    ungroup()
}
