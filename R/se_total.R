#' Estimate totals of population survey
#'
#' \code{se_estimate()} estimates the frequencies, variance and confidence
#' intervals of FSO population surveys.
#'
#' @param data Tibble
#' @param weight Character string, name of the column containing the
#' weights
#' @param strata Character string, name of the column containing the
#' strata/zones
#' @param group_vars A character vector of grouping variables.
#' @param condition [Deprecated] Use `group_vars` instead. A character vector of grouping variables.
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @returns Tibble, with the following columns:
#'  \itemize{
#'  \item \code{total}: population estimate
#'  \item \code{vhat}: estimated variance
#'  \item \code{occ}: true frequency in survey sample
#'  \item \code{stand_dev}: standard deviation
#'  \item \code{ci}: absolute confidence interval
#'  \item \code{ci_per}: percent confidence interval.
#'  }
#'
#' @examples
#' # One grouping variable
#' se_total(
#'   data = nhanes,
#'   weight = "weights",
#'   strata = "strata",
#'   group_vars = "gender"
#' )
#' # Multiple grouping variables
#' library(dplyr)
#' library(purrr)
#' map(
#'   c("gender", "marital_status"),
#'   ~ se_total(
#'     data = nhanes,
#'     weight = "weights",
#'     strata = "strata",
#'     group_vars = .x
#'   ) %>%
#'     mutate(variable = .x, .before = 1) %>%
#'     rename_with(~"value", all_of(.x))
#' ) %>%
#'   map_dfr(~ .x %>% as_tibble())
#'
#' @import dplyr
#' @importFrom stats qnorm weighted.mean
#'
#' @export

se_total <- function(data, weight,
                     strata = "zone",
                     group_vars = NULL,
                     condition = NULL,
                     alpha = 0.05) {
  mh <- Nh <- mhc <- Nhc <- T1h <- T1hc <- T2hc <- vhat <- stand_dev <- ci <- total <- occ <- ci_per <- NULL

  if (!is.null(condition)) {
    warning("Argument `condition` is deprecated. Please use `group_vars` instead.", call. = FALSE)
    if (is.null(group_vars)) {
      group_vars <- condition
    }
  }

  # Summarise by strata
  data <- se_summarise(
    data = data, strata = strata,
    weight = weight
  ) %>%
    # First summation term (1)
    mutate(T1h = if_else(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0)) %>%
    # Summarise by strata and grouping_variables
    se_summarise(
      strata = c(strata, group_vars),
      weight = weight,
      mh_col = "mhc", Nh_col = "Nhc"
    ) %>%
    # Second summation term 1/2
    mutate(T1hc = (mh - mhc) * (Nhc / mh)^2)

  data %>%
    group_by(across(c(all_of(strata), all_of(group_vars)))) %>%
    # Second summation term 2/2
    summarise(T2hc = sum((.data[[weight]] - Nhc / mh)^2)) %>%
    left_join(
      distinct(data, across(c(
        all_of(strata),
        all_of(group_vars), T1h, T1hc, mhc, Nhc
      ))),
      .,
      by = c(strata, group_vars)
    ) %>%
    ungroup() %>%
    group_by(across(all_of(group_vars))) %>%
    summarise(
      # Variance estimate
      vhat = sum(T1h * (T1hc + T2hc)),
      # Population estimate
      total = sum(Nhc),
      # True occurrence in survey sample
      occ = sum(mhc)
    ) %>%
    ungroup() %>%
    mutate(
      # Standard deviation
      stand_dev = sqrt(vhat),
      # Absolute confidence interval
      ci = stand_dev * qnorm(1 - alpha / 2),
      # Percent confidence interval
      ci_per = ci / total * 100
    ) %>%
    # Order as desired
    select(all_of(group_vars), occ, total, vhat, stand_dev, ci, ci_per)
}
