#' Estimate Means of Mobility Survey
#'
#' \code{mzmv_mean()} estimates the mean frequencies and confidence
#' intervals of FSO mobility surveys.
#'
#' @param data A tibble or data frame.
#' @param ... Unquoted names of variables to be estimated. Variables have integer values, representing a quantity (number of cars per household) or presence/absence (possession of a car). Negative numbers represent `NA`.
#' @param weight Unquoted name of the column containing the sample
#' weights.
#' @param cf Double, correction factor of the confidence interval, supplied by FSO. Default is 1.14.
#' @param alpha Double, significance level. Default 0.1 for 90\% confidence interval.
#'
#' @returns Tibble (number of rows is length of \code{variable}) with the following columns:
#' \itemize{
#' \item \code{id}: estimated item
#' \item \code{nc}: number of survey responses
#' \item \code{wmean}: weighted mean estimate
#' \item \code{ci}: confidence interval estimate
#' }
#'
#' @seealso See \code{\link{mzmv_mean_map}} for estimates on a set of conditions.
#'
#' @examples
#' library(dplyr)
#' library(purrr)
#' # Estimate two means
#' mzmv_mean(
#' data = nhanes,
#' annual_household_income, annual_family_income,
#' weight = weights
#' )
#' @import dplyr
#' @import purrr
#' @importFrom rlang enquo enquos as_label
#' @importFrom stats weighted.mean
#'
#' @export
#'

mzmv_mean <- function(data, ..., weight, cf = 1.14, alpha = 0.1) {
  
  # Capture variables and weight as quosures
  variables <- enquos(...)
  weight <- enquo(weight)
  
  # Loop over each quosure variable
  map(variables, function(var_quo) {
    var_name <- as_label(var_quo)  # For labeling output
    
    data |>
      filter(!!var_quo >= 0) |>
      summarise(
        nc = n(),
        wmean = if_else(nc == 0, NA_real_,
                        weighted.mean(x = !!var_quo, w = !!weight)),
        ci = if_else(
          nc == 0,
          NA_real_,
          cf * sqrt(sum(!!weight * (!!var_quo - wmean)^2) /
                      (sum(!!weight) - 1) / nc) *
            qnorm(1 - alpha / 2)
        ),
        .groups = "drop"
      ) |>
      mutate(variable = var_name, .before = 1)
  }) |>
    list_rbind()
}

#' Estimate means of mobility survey with conditions
#'
#' \code{mzmv_mean_map()} estimates the mean frequencies and confidence
#' intervals of FSO mobility surveys for a given set of features.
#'
#' @param data Tibble
#' @param variable Vector of strings, names of variables to be estimated. Variables have integer values, representing a quantity (number of cars per household) or presence/absence (possession of a car). Negative numbers represent `NA`.
#' @param group_vars A character vector of grouping variables.
#' @param condition [Deprecated] Use `group_vars` instead. A character vector of grouping variables.
#' @param weight Character string, name of the column containing the
#' weights
#' @param cf Double, correction factor of the confidence interval, supplied by FSO
#' @param alpha Double, significance level. Default 0.1 for 90\% confidence interval.
#'
#' @returns Tibble (number of rows is length of \code{variable}) with the following columns:
#' \itemize{
#' \item \code{id}: estimated item
#' \item \code{nc}: number of survey responses
#' \item \code{wmean}: weighted mean estimate
#' \item \code{ci}: confidence interval estimate
#' }
#'
#' @examples
#' # We can use the nhanes dataset as an example even if it only contains population data
#' library(dplyr)
#' library(purrr)
#' mzmv_mean_map(
#' data = nhanes,
#' variable = c("annual_household_income", "annual_family_income"),
#' group_vars = c("gender", "interview_lang"),
#' weight = "weights"
#' )
#'
#' @import dplyr
#' @import purrr
#'
#' @export
#'
mzmv_mean_map <- function(data, variable, group_vars = NULL, condition = NULL, weight, cf = 1.14, alpha = 0.1) {

  # ci <- condition_value <- nc <- wmean <- group_vars_value <- NULL
  # 
  # # If grouping variable is "all", add a dummy column for grouping
  # if (is.null(group_vars)) {
  #   # Add a dummy column for grouping
  #   data <- data |>
  #     mutate(group_dummy = "all")
  #   group_vars <- "group_dummy" # Set grouping variable to the dummy column
  # }
  # 
  # # Continue as normal with grouping
  # group_vars |>
  #   purrr::set_names() |>
  #   map(\(cond) {
  #     cond_var <- sym(cond)
  #     mzmv_mean(
  #       data = data |> group_by(!!cond_var),
  #       variable = variable,
  #       weight = weight,
  #       alpha = alpha,
  #       cf = cf
  #     )
  #   }) |>
  #   purrr::list_rbind(names_to = "group_vars") |>
  #   mutate(group_vars_value = coalesce(!!!syms(group_vars))) |>
  #   select(variable, group_vars, group_vars_value, nc, wmean, ci)
}

#' Estimate proportions from mobility survey
#'
#' \code{mzmv_prop} estimates the proportions and confidence intervals of FSO mobility survey data
#'
#' @param data Tibble
#' @param variable Vector of strings, names of variables to be estimated. Variables are binary with integer values:
#' \itemize{
#' \item 1: if group_vars is present
#' \item 0: if group_vars is absent
#' \item negative: if \code{NA}
#' }
#' @param weight Character string, name of the column containing the
#' weights
#' @param cf Double, correction factor of the confidence interval, supplied by FSO
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @returns Vector, with the following values:
#' \itemize{
#' \item \code{p}: proportion estimate
#' \item \code{ci}: confidence interval estimate
#' }
#'
#' @examples
#' # We can use the nhanes dataset
#' library(dplyr)
#' nhanes |>
#'   mutate(
#'     married =
#'       case_when(
#'         marital_status == "Married" ~ 1,
#'         TRUE ~ 0
#'       )
#'   ) |>
#'   mzmv_prop(
#'     variable = "married",
#'     weight = "weights"
#'   )
#'
#' @import dplyr
#'
#' @export
#'
mzmv_prop <- function(data, variable, weight, cf = 1.14, alpha = 0.1) {
  
  # ci <- p <- nc <- NULL
  # 
  # p <- NULL
  # data |>
  #   filter(.data[[variable]] >= 0) |>
  #   summarise(
  #     nc = n(),
  #     p = weighted.mean(x = .data[[variable]], w = .data[[weight]]),
  #     ci = cf * sqrt(p * (1 - p) / n()) * qnorm(1 - alpha / 2)
  #   )
}
