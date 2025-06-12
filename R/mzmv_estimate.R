#' Estimate Means of Mobility Survey
#'
#' \code{mzmv_mean()} estimates the means, proportions and confidence
#' intervals of FSO mobility surveys.
#'
#' @param data A data frame or tibble.
#' @param ... Names of variables to be estimated. Can be passed unquoted (e.g., \code{household_size}) or programmatically using \code{!!!syms(c("annual_household_income", "household_size"))}.
#' Variables have integer values, representing a quantity (number of cars per household) or presence/absence (possession of a car). Negative numbers represent \code{NA}.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param cf Numeric correction factor of the confidence interval, supplied by FSO. Default is 1.14.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.1 (90\% CI).
#'
#' @returns Tibble (number of rows is length of \code{variable}) with the following columns:
#' \itemize{
#' \item \code{id}: estimated item
#' \item \code{occ}: number of survey responses
#' \item \code{wmean}: weighted mean estimate
#' \item \code{ci}: confidence interval estimate
#' }
#'
#' @seealso See \code{\link{mzmv_mean_map}} for estimates on a set of conditions.
#'
#' @examples
#' # Estimate two means
#' mzmv_mean(
#'   data = nhanes,
#'   annual_household_income, annual_family_income,
#'   weight = weights
#' )
#' # Programmatic use with strings
#' v <- c("annual_household_income", "annual_family_income")
#' mzmv_mean(nhanes, weight = "weights", !!!rlang::syms(v))
#'
#' @import dplyr
#' @import purrr
#' @importFrom rlang enquos ensym as_label
#' @importFrom stats weighted.mean
#'
#' @export
#'

mzmv_mean <- function(data, ..., weight, cf = 1.14, alpha = 0.1) {
  variables <- enquos(...)
  weight <- ensym(weight)

  map(variables, function(var_quo) {
    var_name <- as_label(var_quo)

    data |>
      filter(!!var_quo >= 0) |>
      summarise(
        occ = n(),
        wmean = if_else(occ == 0, NA_real_,
          weighted.mean(x = !!var_quo, w = !!weight)
        ),
        ci = if_else(
          occ == 0,
          NA_real_,
          cf * sqrt(sum(!!weight * (!!var_quo - wmean)^2) /
            (sum(!!weight) - 1) / occ) *
            qnorm(1 - alpha / 2)
        ),
        .groups = "drop"
      ) |>
      mutate(variable = var_name, .before = 1)
  }) |>
    list_rbind()
}

#' Estimate Means in Parallel for Multiple Grouping Variables in Mobility Survey
#'
#' @description
#' \code{mzmv_mean_map()} estimates weighted means and confidence intervals for a set of features of the mobility survey, optionally grouped by one or more variables.
#'
#' @param data A data frame or tibble.
#' @param variable Character vector of variable names to be estimated. Must be quoted (e.g., \code{"annual_family_income"}). For multiple variables, pass as a vector (e.g., \code{c("annual_family_income", "annual_household_income")}).
#' Does not support bare (unquoted) variable names.
#' @param ... Grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or quoted (e.g., \code{"gender"}, \code{"birth_country"}). If omitted, results are aggregated across the whole dataset.
#' @param weight Unquoted or quoted name of the sampling weights column (must exist in \code{data}). For programmatic use with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param cf Numeric correction factor for the confidence interval. Default is 1.14.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.1 (90\% CI).
#'
#' @returns A tibble with columns:
#' \describe{
#'   \item{variable}{Name of the estimated variable.}
#'   \item{group_vars}{Name of the grouping variable.}
#'   \item{group_vars_value}{Value of the grouping variable.}
#'   \item{occ}{Number of cases or observations.}
#'   \item{wmean}{Weighted mean.}
#'   \item{ci}{Confidence interval.}
#' }
#'
#' @importFrom dplyr group_by mutate select
#' @importFrom purrr map map_dfr set_names
#' @importFrom rlang enquos as_label sym syms ensym is_symbolic
#'
#' @export
#'
#' @examples
#' # Multiple quoted variables
#' mzmv_mean_map(
#'   nhanes,
#'   variable = c("annual_family_income", "annual_household_income"),
#'   gender,
#'   birth_country,
#'   weight = weights
#' )
#' # No grouping variables
#' mzmv_mean_map(
#'   nhanes,
#'   variable = "annual_family_income",
#'   weight = weights
#' )
#' # Programmatic use
#' wt <- "weights"
#' mzmv_mean_map(
#'   nhanes,
#'   variable = "annual_family_income",
#'   gender,
#'   birth_country,
#'   weight = !!rlang::sym(wt)
#' )
#'
mzmv_mean_map <- function(data, variable, ..., weight, cf = 1.14, alpha = 0.1) {
  group_quo <- enquos(...)
  group_vars <- map_chr(group_quo, as_label)
  weight <- ensym(weight)
  variable_syms <- map(variable, sym)

  # Ensure variable is a character vector or list of symbols
  if (is_symbolic(variable)) {
    variable <- as_label(variable)
  }
  if (is.character(variable)) {
    variable <- as.list(variable)
  }
  if (!is.list(variable)) {
    variable <- list(variable)
  }

  # Handle empty group_vars case
  if (length(group_vars) == 0) {
    data <- data |> mutate(.dummy_group = "all")
    group_vars <- ".dummy_group"
  }

  # Validate columns
  validate_column <- function(col) {
    if (!col %in% names(data)) {
      stop(paste("Column", col, "not found in data frame"))
    }
  }
  walk(group_vars, validate_column)
  walk(variable, validate_column)
  validate_column(as_label(weight))

  map_dfr(variable_syms, function(v) {
    group_vars |>
      set_names() |>
      map(~ {
        data |>
          group_by(!!sym(.x)) |>
          mzmv_mean(
            !!v,
            weight = !!weight,
            cf = cf,
            alpha = alpha
          )
      }) |>
      list_rbind(names_to = "group_vars") |>
      mutate(
        variable = as_label(v),
        group_vars_value = coalesce(!!!syms(group_vars))
      ) |>
      select(
        variable,
        group_vars,
        group_vars_value,
        occ, wmean, ci
      )
  })
}
