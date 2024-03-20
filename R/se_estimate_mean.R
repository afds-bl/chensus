#' Estimate means of population surveys
#'
#' \code{se_estimate_mean()} estimates the proportions of categorical variables
#' and averages of numeric variables along with the variance and confidence
#' intervals of the Strukturerhebung / relevé struturel of BFS/OFS/FSO.
#'
#' @param data Tibble
#' @param variable Character string, name of the feature whose mean we would like
#' to estimate
#' @param var_type Charcter string, variable type, one of "cat" or "num"
#' @param strata Character string, name of the column containing the
#' strata/zones
#' @param weight Character string, name of the column containing the
#' weights
#' @param condition condition Vector of character strings, names of additional
#' stratification variables
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @return Tibble, with the following columns:
#'  \itemize{
#'  \item{\code{occ}: }{true frequency in survey sample}
#'  \item{\code{average}: }{estimated mean}
#'  \item{\code{vhat}: }{estimated variance}
#'  \item{\code{stand_dev}: }{standard deviation}
#'  \item{\code{ci}: }{absolute confidence interval}
#'  }
#' @import dplyr
#' @export
#'
#' @examples
#' se_estimate_mean(
#'   data = nhanes,
#'   variable = "age",
#'   var_type = "num",
#'   strata = "strata",
#'   weight = "weights",
#'   condition = "gender"
#' )
#'
se_estimate_mean <- function(data, variable, var_type, strata = "zone", weight, condition = NULL, alpha = 0.05) {
  mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- occ <- nc <- ybar <- zk <- zhat <- vhat <- stand_dev <- ci <- total <- occ <- ci_per <- NULL

    stopifnot("`var_type` should be either 'cat' or 'num'" = var_type %in% c("cat", "num"))

  data |>
    filter(.data[[variable]] >= 0) |>
    mutate(yk = .data[[variable]]) |>
    mutate(
      occ = if_else(var_type == "cat", sum(yk == 1), n()),
      nc = sum(.data[[weight]]),
      ybar = weighted.mean(yk, w = .data[[weight]]),
      zk = (yk - ybar) / nc, .by = all_of(condition)
    ) |>
    mutate(
      mh = n(),
      Nh = sum(.data[[weight]]),
      T1h = if_else(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
      zhat = .data[[weight]] * zk,
      T2h = (.data[[weight]] * zk - zhat / mh)^2, .by = c(strata, all_of(condition))
    ) |>
    summarise(sum_T2h = sum(T2h), T1h = unique(T1h), occ = unique(occ), ybar = unique(ybar), .by = c(strata, all_of(condition))) |>
    summarise(
      occ = unique(occ),
      average = unique(ybar),
      vhat = sum(T1h * sum_T2h), .by = all_of(condition)
    ) |>
    mutate(
      # Standard deviation
      stand_dev = sqrt(vhat),
      # Absolute confidence interval
      ci = stand_dev * qnorm(1 - alpha / 2)
    )
}
