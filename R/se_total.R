#' Estimate Totals of Structural Survey
#'
#' \code{se_total()} estimates the totals, variance, and confidence
#' intervals of FSO structural surveys.
#'
#' @param data A tibble or data frame.
#' @param ... Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#' @param condition (deprecated) A character vector of grouping variables. Use \code{...} instead.
#'
#' @details
#' 
#' The \code{condition} argument has been removed and should not be used. Grouping variables 
#' can be passed unquoted or programmatically using \code{rlang}:
#' 
#' * Interactive use:
#' 
#'   \code{se_total(data, weight = my_weight, group1, group2)}
#'   
#' * Programmatic use:
#'   
#'   \code{group_vars <- c("group1", "group2")}
#'   
#'   \code{se_total(data, weight = !!rlang::sym(weight_var), !!!rlang::syms(group_vars))}
#' 
#' @returns A tibble with estimates for all grouping column combinations, including:
#' \describe{
#'   \item{<variable>}{Value of the grouping variables passed in \code{...}.}
#'    \item{occ}{number of observations in survey sample.}
#'    \item{total}{population estimate.}
#'    \item{vhat, stand_dev}{Estimated variance of the mean (\code{vhat}) and its standard deviation (\code{stand_dev} (square root of the variance).}
#'   \item{ci, ci_per, ci_l, ci_u}{Confidence interval:  half-width (\code{ci}), percentage of the mean (\code{ci_per}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
#'  }
#'
#' @seealso \code{\link[=se_total_map]{se_total_map()}}
#'
#' @import dplyr
#' @importFrom purrr map_chr
#' @importFrom rlang enquo enquos as_label sym syms ensym
#' @importFrom stats qnorm
#'
#' @export
#'
#' @examples
#' # One grouping variable
#' se_total(
#'   data = nhanes,
#'   strata = strata,
#'   weight = weights,
#'   gender
#' )
#' # Multiple grouping variables
#' se_total(
#'   data = nhanes,
#'   strata = strata,
#'   weight = weights,
#'   gender, marital_status, birth_country
#' )
#'
se_total <- function(data, ..., strata, weight, alpha = 0.05) {
  # Capture symbols for tidy evaluation
  weight <- ensym(weight)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  group_vars <- enquos(...)

  # Named joining vector
  by_cols <- c(as_label(strata), map_chr(group_vars, as_label))
  by_vec <- set_names(by_cols)

  # Summarise by strata
  data <- se_summarise(
    data = data,
    weight = !!weight,
    !!strata
  ) |>
    mutate(T1h = if_else(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0)) |>
    # Summarise by strata and grouping variables
    se_summarise(
      weight = !!weight,
      mh_col = "mhc", Nh_col = "Nhc",
      !!strata, !!!group_vars
    ) |>
    mutate(T1hc = (mh - mhc) * (Nhc / mh)^2)

  data |>
    group_by(!!strata, !!!group_vars) |>
    summarise(T2hc = sum((!!weight - Nhc / mh)^2), .groups = "drop") |>
    left_join(
      distinct(data, !!strata, !!!group_vars, T1h, T1hc, mhc, Nhc),
      by = by_vec
    ) |>
    group_by(!!!group_vars) |>
    summarise(
      vhat = sum(T1h * (T1hc + T2hc)),
      total = sum(Nhc),
      occ = sum(mhc),
      .groups = "drop"
    ) |>
    mutate(
      stand_dev = sqrt(vhat),
      ci = stand_dev * qnorm(1 - alpha / 2),
      ci_per = ci / total * 100,
      ci_l = total - ci,
      ci_u = total + ci
    ) |>
    select(!!!group_vars, occ, total, vhat, stand_dev, starts_with("ci"))
}

#' Estimate Totals in Parallel for Multiple Grouping Variables in Structural Survey
#'
#' `se_total_map()` applies `se_total()` to a data frame for each of several grouping variables, returning a combined tibble of results.
#'
#' This wrapper function allows to efficiently compute totals and confidence intervals for each grouping variable in the structural survey data in parallel.
#'
#' @param data A tibble or data frame.
#' @param ... One or more grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' 
#' @returns A tibble with results for each grouping variable, including:
#' \describe{
#'    \item{variable}{The name of the grouping variable.}
#'    \item{value}{The value of the grouping variable.}
#'    \item{occ}{Sample size for the group.}
#'    \item{total}{Estimated total for the group.}
#'    \item{vhat, stand_dev}{Estimated variance of the mean (\code{vhat}) and its standard deviation (\code{stand_dev} (square root of the variance).}
#'    \item{ci, ci_per, ci_l, ci_u}{Confidence interval:  half-width (\code{ci}), percentage of the mean (\code{ci_per}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
#' }
#'
#' @details
#' This function iterates over each grouping variable supplied via `...`, applies `se_total()` to the data grouped by that variable, and combines the results into a single tibble. The grouping variable is renamed to `value` and its name is stored in the `variable` column for clarity.
#'
#' @seealso \code{\link[=se_total]{se_total()}}
#' @import dplyr
#' @importFrom purrr map_chr
#' @importFrom rlang enquo enquos as_label sym syms
#' @importFrom stats qnorm
#' @examples
#' # Estimate totals for gender, marital_status, and birth_country in parallel
#' se_total_map(
#'   nhanes,
#'   weight = weights,
#'   strata = strata,
#'   gender, marital_status, birth_country
#' )
#' # Programmatic use with strings
#' v <- c("gender", "marital_status", "birth_country")
#' se_total_map(
#'   nhanes,
#'   weight = "weights",
#'   strata = "strata",
#'   !!!rlang::syms(v)
#' )
#'
#' @export
#'
se_total_map <- function(data, ..., strata, weight, alpha = 0.05) {
  group_quos <- enquos(...)

  map(
    group_quos,
    ~ {
      # .x is a quosure
      col_name <- as_label(.x)
      data |>
        se_total(strata = {{ strata }}, weight = {{ weight }}, alpha = alpha, !!.x) |>
        mutate(variable = col_name, .before = 1) |>
        rename_with(~"value", all_of(col_name))
    }
  ) |>
    bind_rows()
}
