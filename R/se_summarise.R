#' Summarise Structural Survey Data by Group
#'
#' \code{se_summarise()} is a helper function for \code{\link[=se_total]{se_total()}}. It calculates survey-weighted group-level summaries by adding columns for the number
#' of observations and the estimated population size per group.
#'
#' @param data A data frame or tibble.
#' @param ... One or more grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param weight The name of the weight column. Can be passed unquoted, quoted, or programmatically using \code{!!sym(wt)} where \code{wt} is a character variable.
#' @param mh_col A character string specifying the name of the column for the number of observations (respondents) per group. Default is `"mh"`.
#' @param Nh_col A character string specifying the name of the column for the estimated population size per group. Default is `"Nh"`.
#'
#' @returns
#' A tibble containing the original data with two additional columns \code{mh_col} and \code{Nh_col} (or their specified names).
#'
#' @examples
#' # One grouping variable
#' se_summarise(nhanes, weight = weights, strata)
#' # Two grouping variables
#' se_summarise(nhanes,
#'   weight = weights,
#'   mh_col = "mhc",
#'   Nh_col = "Nhc",
#'   strata, gender
#' )
#'
#' @keywords internal
#' 
#' @importFrom rlang enquos ensym
#' @import dplyr
#'
#' @export

se_summarise <- function(data, ..., weight, mh_col = "mh", Nh_col = "Nh") {
  weight_quo <- ensym(weight)
  group_quos <- enquos(...)

  data |>
    group_by(!!!group_quos) |>
    add_count(name = mh_col) |>
    add_count(wt = !!weight_quo, name = Nh_col) |>
    ungroup()
}
