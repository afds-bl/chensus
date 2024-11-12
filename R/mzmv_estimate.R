#' Estimate means of mobility survey
#'
#' \code{mzmv_estimate_mean()} estimates the mean frequencies and confidence
#' intervals of FSO mobility surveys.
#'
#' @param data Tibble
#' @param variable Vector of strings, names of variables to be estimated. Variables have integer values, representing a quantity (number of cars per household) or presence/absence (possession of a car). Negative numbers represent `NA`.
#' @param weight Character string, name of the column containing the
#' weights
#' @param cf Double, correction factor of the confidence interval, supplied by FSO
#' @param alpha Double, significance level. Default 0.1 for 90\% confidence interval.
#'
#' @returns Tibble (number of rows is length of \code{variable}) with the following columns:
#' \itemize{
#' \item{\code{id}: }{estimated item}
#' \item{\code{nc}: }{number of survey responses}
#' \item{\code{wmean}: }{weighted mean estimate}
#' \item{\code{ci}: }{confidence interval estimate}
#' }
#'
#' @seealso See \code{\link{mzmv_estimate_mean_map}} for estimates on a set of conditions.
#'
#' @examples
#' # We can use the nhanes dataset as an example even if it only contains population data
#' library(dplyr)
#' library(purrr)
#' # Estimate two means
#' mzmv_estimate_mean(
#'   c("annual_household_income", "annual_family_income"),
#'   data = nhanes,
#'   weight = "weights",
#'   alpha = 0.1
#' )
#' @import dplyr
#' @import purrr
#'
#' @export
#'
mzmv_estimate_mean <- function(data, variable, weight, cf = 1.14, alpha = 0.1) {
  variable %>%
    purrr::set_names() %>% # Output is a list whose elements are named using variable
    map(\(v) {
      group_var <- sym(v)
      weight_var <- sym(weight)
      data %>%
        filter(!!group_var >= 0) %>%
        summarise(
          nc = n(),
          wmean = if_else(nc == 0, NA, weighted.mean(x = !!group_var, w = !!weight_var)),
          ci = if_else(nc == 0, NA, cf * sqrt(sum(!!weight_var * (!!group_var - wmean)^2) / (sum(!!weight_var) - 1) / nc) * qnorm(1 - alpha / 2)),
          .groups = "drop"
        )
    }) %>%
    list_rbind(names_to = "variable") # Convert into a table
}

#' Estimate means of mobility survey with conditions
#'
#' \code{mzmv_estimate_mean_map()} estimates the mean frequencies and confidence
#' intervals of FSO mobility surveys for a given set of features.
#'
#' @param data Tibble
#' @param variable Vector of strings, names of variables to be estimated. Variables have integer values, representing a quantity (number of cars per household) or presence/absence (possession of a car). Negative numbers represent `NA`.
#' @param condition Vector of character strings, names of additional
#' stratification variables
 #' @param weight Character string, name of the column containing the
#' weights
#' @param cf Double, correction factor of the confidence interval, supplied by FSO
#' @param alpha Double, significance level. Default 0.1 for 90\% confidence interval.
#'
#' @returns Tibble (number of rows is length of \code{variable}) with the following columns:
#' \itemize{
#' \item{\code{id}: }{estimated item}
#' \item{\code{nc}: }{number of survey responses}
#' \item{\code{wmean}: }{weighted mean estimate}
#' \item{\code{ci}: }{confidence interval estimate}
#' }
#'
#' @examples
#' # We can use the nhanes dataset as an example even if it only contains population data
#' library(dplyr)
#' library(purrr)
#' mzmv_estimate_mean_map(
#' data = nhanes,
#' variable = c("annual_household_income", "annual_family_income"),
#' condition = c("gender", "interview_lang"),
#' weight = "weights"
#' )
#'
#' @import dplyr
#' @import purrr
#'
#' @export
#'
mzmv_estimate_mean_map <- function(data, variable, condition = NULL, weight, cf = 1.14, alpha = 0.1) {

  # If condition is "all", add a dummy column for grouping
  if (is.null(condition)) {
    # Add a dummy column for grouping
    data <- data |>
      mutate(group_dummy = "all")
    condition <- "group_dummy" # Set condition to the dummy column
  }

  # Continue as normal with grouping
  condition |>
    purrr::set_names() |>
    map(\(cond) {
      cond_var <- sym(cond)
      mzmv_estimate_mean(
        data = data |> group_by(!!cond_var),
        variable = variable,
        weight = weight,
        alpha = alpha,
        cf = cf
      )
    }) |>
    purrr::list_rbind(names_to = "condition") |>
    mutate(condition_value = coalesce(!!!syms(condition))) |>
    select(variable, condition, condition_value, nc, wmean, ci)
}

#' Estimate proportions from mobility survey
#'
#' \code{mzmv_estimate_prop} estimates the proportions and confidence intervals of FSO mobility survey data
#'
#' @param data Tibble
#' @param variable Vector of strings, names of variables to be estimated. Variables are binary with integer values:
#' \itemize{
#' \item{1: }{if condition is present}
#' \item{0: }{if condition is absent}
#' \item{negative: }{if \code{NA}}
#' }
#' @param weight Character string, name of the column containing the
#' weights
#' @param cf Double, correction factor of the confidence interval, supplied by FSO
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @returns Vector, with the following values:
#' \itemize{
#' \item{\code{p}: }{proportion estimate}
#' \item{\code{ci}: }{confidence interval estimate}
#' }
#'
#' @examples
#' # We can use the nhanes dataset
#' library(dplyr)
#' nhanes %>%
#'   mutate(
#'     married =
#'       case_when(
#'         marital_status == "Married" ~ 1,
#'         TRUE ~ 0
#'       )
#'   ) %>%
#'   mzmv_estimate_prop(
#'     variable = "married",
#'     weight = "weights"
#'   )
#'
#' @import dplyr
#'
#' @export
#'
mzmv_estimate_prop <- function(data, variable, weight, cf = 1.14, alpha = 0.1) {
  p <- NULL
  data %>%
    filter(.data[[variable]] >= 0) %>%
    summarise(
      nc = n(),
      p = weighted.mean(x = .data[[variable]], w = .data[[weight]]),
      ci = cf * sqrt(p * (1 - p) / n()) * qnorm(1 - alpha / 2)
    )
}
