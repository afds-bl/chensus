#' Estimate Totals of Structural Survey
#'
#' \code{se_total()} estimates the totals, variance, and confidence
#' intervals of FSO structural surveys.
#'
#' @param data A tibble or data frame.
#' @param weight Unquoted column name of the column containing the weights.
#' @param strata Unquoted column name of the column containing the strata. Default is \code{zone}.
#' @param ... Additional unquoted grouping variables (e.g., \code{gender}, \code{marital_status}).
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @return A tibble with estimates for all grouping column combinations, including:
#' \describe{
#'    \item{total}{population estimate.}
#'    \item{vhat}{estimated variance.}
#'    \item{occ}{true frequency in survey sample.}
#'    \item{stand_dev}{standard deviation.}
#'    \item{ci}{absolute confidence interval.}
#'    \item{ci_per}{percent confidence interval.}
#'    \item{ci_l}{Lower confidence interval bound.}
#'    \item{ci_u}{Upper confidence interval bound.}
#'  }
#'
#' @seealso \code{\link[=se_total_map]{se_total_map()}}
#' 
#' @examples
#' # One grouping variable
#' se_total(
#'   data = nhanes,
#'   weight = weights,
#'   strata = strata,
#'   gender
#' )
#' # Multiple grouping variables
#' se_total(
#'   data = nhanes,
#'   weight = weights,
#'   strata = strata,
#'   gender, marital_status, birth_country
#' )
#'
#' @import dplyr
#' @importFrom purrr map_chr
#' @importFrom rlang enquo enquos as_label
#' @importFrom stats qnorm
#'
#' @export

se_total <- function(data, ..., weight, strata, alpha = 0.05) {
  mh <- Nh <- mhc <- Nhc <- T1h <- T1hc <- T2hc <- total <- ci_per <- NULL
  
  # Capture quosures for tidy evaluation
  weight <- enquo(weight)
  strata <- if (missing(strata)) sym("zone") else enquo(strata)
  group_vars <- enquos(...)
  
  # Named joining vector
  by_cols <- c(as_label(strata), map_chr(group_vars, as_label))
  by_vec  <- set_names(by_cols)
  
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
#' This wrapper function allows to efficiently compute totals, variances, and confidence intervals for each grouping variable in the structural survey data, using the tidyverse with unquoted column names.
#'
#' @param data A tibble or data frame.
#' @param weight Unquoted column name for the sampling weights.
#' @param strata Unquoted column name for the strata. Default is \code{zone}.
#' @param ... One or more unquoted grouping variables (e.g., `gender`, `marital_status`, `birth_country`).
#'
#' @return A tibble with results for each grouping variable, including:
#' \describe{
#'    \item{variable}{The name of the grouping variable.}
#'    \item{value}{The value of the grouping variable.}
#'    \item{occ}{Sample size for the group.}
#'    \item{total}{Estimated total for the group.}
#'    \item{vhat}{Estimated variance.}
#'    \item{stand_dev}{Standard deviation.}
#'    \item{ci}{Absolute confidence interval.}
#'    \item{ci_per}{Percent confidence interval.}
#'    \item{ci_l}{Lower confidence interval bound.}
#'    \item{ci_u}{Upper confidence interval bound.}
#' }
#'
#' @details
#' This function iterates over each grouping variable supplied via `...`, applies `se_total()` to the data grouped by that variable, and combines the results into a single tibble. The grouping variable is renamed to `value` and its name is stored in the `variable` column for clarity.
#'
#' @seealso \code{\link[=se_total]{se_total()}}
#'
#' @examples
#' # Estimate totals for gender, marital_status, and birth_country
#' se_total_map(
#'   nhanes,
#'   weight = weights,
#'   strata = strata,
#'   gender, marital_status, birth_country
#' )
#'
#' @export
#' 
se_total_map <- function(data, ..., weight, strata) {
  group_quos <- enquos(...)
  
  map(
    group_quos,
    ~ {
      # .x is a quosure
      col_name <- as_label(.x)
      data |>
        se_total(weight = {{weight}}, strata = {{strata}}, !!.x) |>
        mutate(variable = col_name, .before = 1) |>
        rename_with(~"value", all_of(col_name))
    }
  ) |>
    bind_rows()
}
