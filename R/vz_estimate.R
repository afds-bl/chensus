#' Estimates from population survey
#'
#' \code{vz_estimate()} estimates the frequencies, variance and confidence
#' intervals of BFS/OFS population surveys.
#'
#' @param data Tibble
#' @param weight Character string, name of the column containing the
#' weights
#' @param strata Character string, name of the column containing the
#' strata/zones
#' @param condition Vector of character strings, names of the conditions to
#' estimate, can be empty for total population estimate
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @returns Tibble, with the following columns:
#'  \itemize{
#'  \item{\code{total}: }{population estimate}
#'  \item{\code{vhat}: }{estimated variance}
#'  \item{\code{occ}: }{true frequency in survey sample}
#'  \item{\code{sd}: }{standard deviation}
#'  \item{\code{ci}: }{absolute confidence interval}
#'  \item{\code{ci_per}: }{percent confidence interval.}
#'  }
#'
#' @examples
#' # One condition
#' vz_estimate(
#'   data = nhanes,
#'   weight = "weights",
#'   strata = "strata",
#'   condition = "gender"
#' )
#' # Multiple conditions
#' library(dplyr)
#' purrr::map(
#'   c("gender", "marital_status"),
#'   ~ vz_estimate(
#'     data = nhanes,
#'     weight = "weights",
#'     strata = "strata",
#'     condition = .x
#'   ) %>%
#'     mutate(variable = .x, .before = 1) %>%
#'     rename_with(~"value", all_of(.x))
#' ) %>%
#'   purrr::map_dfr(~ .x %>% as_tibble())
#'
#' @import dplyr
#'
#' @export

vz_estimate <- function(data, weight,
                              strata = "zone",
                              condition = NULL,
                              alpha = 0.05) {
  # Summarise by strata
  data <- vz_summarise(
    data = data, strata = strata,
    weight = weight) %>%
    # First summation term (1)
    mutate(T1h = mh / (mh - 1) * (1 - mh / Nh)) %>%
    # Summarise by strata and conditions
    vz_summarise(.,
      strata = c(strata, condition),
      weight = weight,
      mh_col = "mhc", Nh_col = "Nhc"
    ) %>%
    # Second summation term 1/2
    mutate(T1hc = (mh - mhc) * (Nhc / mh)^2)

  data %>%
    group_by(across(c(all_of(strata), all_of(condition)))) %>%
    # Second summation term 2/2
    summarise(T2hc = sum((.data[[weight]] - Nhc / mh)^2)) %>%
    left_join(
      distinct(data, across(c(
        all_of(strata),
        all_of(condition), T1h, T1hc, mhc, Nhc
      ))),
      .,
      by = c(strata, condition)
    ) %>%
    group_by(across(all_of(condition))) %>%
    summarise(
      # Variance estimate
      vhat = sum(T1h * (T1hc + T2hc)),
      # Population estimate
      total = sum(Nhc),
      # True occurrence in survey sample
      occ = sum(mhc)
    ) %>%
    mutate(
      # Standard deviation
      sd = sqrt(vhat),
      # Absolute confidence interval
      ci = sd * qnorm(1 - alpha / 2),
      # Percent confidence interval
      ci_per = ci / total * 100
    ) %>%
    # Order as desired
    select(all_of(condition), total, vhat, occ, sd, ci, ci_per)
}
