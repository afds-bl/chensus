#' Estimate population from survey samples
#'
#' This function estimates the populations, variance and confidence intervals
#' from survey samples  (Strukturerhebung, relevé structurel) provided by the
#' Bundesamt für Statistik / Office Fédéral
#' des Statistiques.
#'
#' @param data Tibble
#' @param weight_colname Character string, name of the column containing the weights
#' @param strata_variable Character string, name of the column containing the strata/zones
#' @param condition_col Vector of strings, names of the conditions to estimate,
#' can be empty for total population estimate
#'
#' @returns Tibble, with the following columns:
#'
#' - `total`: population estimate;
#' - `vhat`: estimated variance;
#' - `occ`: true frequency in survey sample;
#' - `sd`: standard deviation;
#' - `ci`: absolute confidence interval;
#' - `ci_pers`: percent confidence interval.

estimate_vhat <- function(data, weight_colname, strata_variable = "zone", condition_col = NULL) {
  # Summarise by strata
  data <- summarise_strata(data = data, strata_var = strata_variable, weight_var = weight_colname,
                                 mh_col = "mh", Nh_col = "Nh") %>%
    # First summation term
    mutate(T1h = first_term(mh, Nh)) %>%
    # Summarise by strata and conditions
    summarise_strata(., strata_var = c(strata_variable, condition_col), weight_var = weight_colname,
                           mh_col = "mhc", Nh_col = "Nhc") %>%
    # Second summation term 1/2
    mutate(T1hc = second_term(mh, mhc, Nhc))

  data %>%
    group_by(across(c(all_of(strata_variable), all_of(condition_col)))) %>%
    # Second summation term 2/2
    summarise(T2hc = sum((.data[[weight_colname]] - Nhc/mh)^2)) %>%
    left_join(distinct(data, across(c(all_of(strata_variable), all_of(condition_col), T1h, T1hc, mhc, Nhc)))
              , ., by = c(strata_variable, condition_col)) %>%
    group_by(across(all_of(condition_col))) %>%
    # Variance estimate
    summarise(vhat = sum(terms(T1h, T1hc, T2hc)),
              # Population estimate
              total = sum(Nhc),
              # True occurrence in survey sample
              occ = sum(mhc)) %>%
    # Standard deviation
    mutate(sd = sqrt(vhat),
           # Absolute confidence interval
           ci = sd * qnorm(0.975),
           # Percent confidence interval
           ci_per = ci / total * 100) %>%
    # Order as desired
    select(all_of(condition_col), total, vhat, occ, sd, ci, ci_per)
}


first_term <- function(mh, Nh) mh/(mh - 1) * (1 - mh / Nh)

second_term <- function(mh, mhc, Nhc) (mh - mhc) * (Nhc / mh) ^2

terms <- function(T1h, T1hc, T2hc) T1h * (T1hc + T2hc)
