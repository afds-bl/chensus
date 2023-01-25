#' Estimates from population survey
#'
#' \code{estimate_pop_cens()} estimates the frequencies, variance and confidence
#' intervals from population surveys (Strukturerhebung der Volkzählung, relevé
#' structurel du recensement) provided by the Bundesamt für Statistik / Office
#'  Fédéral de la Statistique.
#'
#' @param data Tibble
#' @param weight_colname Character string, name of the column containing the
#' weights
#' @param strata_variable Character string, name of the column containing the
#' strata/zones
#' @param condition_col Vector of character strings, names of the conditions to
#' estimate, can be empty for total population estimate
#'
#' @returns Tibble, with the following columns:
#'  \itemize{
#'  \item{\code{total}: }{population estimate}
#'  \item{\code{vhat}: }{estimated variance}
#'  \item{\code{occ}: }{true frequency in survey sample}
#'  \item{\code{sd}: }{standard deviation}
#'  \item{\code{ci}: }{absolute confidence interval}
#'  \item{\code{ci_pers}: }{percent confidence interval.}
#'  }
#'
#' @examples
#' estimate_pop_cens(
#'   data = nhanes,
#'   weight_colname = "weights",
#'   strata_variable = "strata",
#'   condition_col = "gender"
#' )
#'
#' @import dplyr
#'
#' @export

estimate_pop_cens <- function(data, weight_colname,
                              strata_variable = "zone",
                              condition_col = NULL) {
  # Summarise by strata
  data <- summarise_pop_cens(
    data = data, strata_variable = strata_variable,
    weight_colname = weight_colname,
    mh_col = "mh", Nh_col = "Nh"
  ) %>%
    # First summation term (1)
    mutate(T1h = mh / (mh - 1) * (1 - mh / Nh)) %>%
    # Summarise by strata and conditions
    summarise_pop_cens(.,
      strata_variable = c(strata_variable, condition_col),
      weight_colname = weight_colname,
      mh_col = "mhc", Nh_col = "Nhc"
    ) %>%
    # Second summation term 1/2
    mutate(T1hc = (mh - mhc) * (Nhc / mh)^2)

  data %>%
    group_by(across(c(all_of(strata_variable), all_of(condition_col)))) %>%
    # Second summation term 2/2
    summarise(T2hc = sum((.data[[weight_colname]] - Nhc / mh)^2)) %>%
    left_join(
      distinct(data, across(c(
        all_of(strata_variable),
        all_of(condition_col), T1h, T1hc, mhc, Nhc
      ))),
      .,
      by = c(strata_variable, condition_col)
    ) %>%
    group_by(across(all_of(condition_col))) %>%
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
      ci = sd * qnorm(0.975),
      # Percent confidence interval
      ci_per = ci / total * 100
    ) %>%
    # Order as desired
    select(all_of(condition_col), total, vhat, occ, sd, ci, ci_per)
}
