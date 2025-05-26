#' Estimate means of numeric variables in structural survey
#'
#' \code{se_mean_num()} estimates the averages of numeric variables along with the variance and confidence
#' intervals of FSO's structural survey (Strukturerhebung / relevé structurel).
#'
#' @param data Tibble
#' @param variable Character string, name of the feature whose mean we would like
#' to estimate
#' @param condition condition Vector of character strings, names of additional
#' stratification variables
#' @param strata Character string, name of the column containing the
#' strata/zones
#' @param weight Character string, name of the column containing the
#' weights
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @return Tibble, with the following columns:
#'  \itemize{
#'  \item \code{occ}: true frequency in survey sample
#'  \item \code{average}: estimated mean
#'  \item \code{vhat}: estimated variance
#'  \item \code{stand_dev}: standard deviation
#'  \item \code{ci}: absolute confidence interval
#'  }
#' @import dplyr
#' @export
#'
#' @examples
#' se_mean_num(
#'   data = nhanes,
#'   variable = "age",
#'   strata = "strata",
#'   weight = "weights",
#'   condition = "gender"
#' )
#'
se_mean_num <- function(data, variable, condition = NULL, strata = "zone", weight, alpha = 0.05) {
  mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- occ <- nc <- ybar <- zk <- zhat <- vhat <- stand_dev <- ci <- total <- occ <- ci_per <- average <- NULL
  
  stopifnot("Variable must be numeric." = is.numeric(data[[variable]]))
  
  data |>
    filter(.data[[variable]] >= 0) |>
    mutate(yk = .data[[variable]]) |>
    mutate(
      occ = n(),
      nc = sum(.data[[weight]]),
      ybar = weighted.mean(yk, w = .data[[weight]]),
      zk = (yk - ybar) / nc, .by = all_of(condition)
    ) |>
    mutate(
      mh = n(),
      Nh = sum(.data[[weight]]),
      T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
      zhat = .data[[weight]] * zk,
      T2h = (.data[[weight]] * zk - zhat / mh)^2, .by = c(all_of(strata), all_of(condition))
    ) |>
    summarise(
      sum_T2h = sum(T2h),
      T1h = unique(T1h),
      occ = unique(occ),
      ybar = unique(ybar),
      .by = c(all_of(strata), all_of(condition))
    ) |>
    summarise(
      occ = unique(occ),
      average = unique(ybar),
      vhat = sum(T1h * sum_T2h),
      .by = all_of(condition)
    ) |>
    mutate(
      stand_dev = sqrt(vhat),
      ci = stand_dev * qnorm(1 - alpha / 2)
    )
}

#' Estimate means of categorical variables in structural survey
#'
#' \code{se_mean_cat()} estimates the proportion of categorical variables along with the variance and confidence
#' intervals of FSO's structural survey (Strukturerhebung / relevé structurel).
#'
#' @param data Tibble
#' @param variable Character string, name of the categorical variable whose proportion we would like
#' to estimate
#' @param condition condition Vector of character strings, names of additional
#' stratification variables
#' @param strata Character string, name of the column containing the
#' strata/zones
#' @param weight Character string, name of the column containing the
#' weights
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @return Tibble, with the following columns:
#'  \itemize{
#'  \item \code{occ}: true frequency in survey sample
#'  \item \code{average}: estimated mean
#'  \item \code{vhat}: estimated variance
#'  \item \code{stand_dev}: standard deviation
#'  \item \code{ci}: absolute confidence interval
#'  }
#' @import dplyr
#' @import stringr
#' @import purrr
#' @export
#'
#' @examples
#' se_mean_cat(
#'   data = nhanes,
#'   variable = "age",
#'   strata = "strata",
#'   weight = "weights",
#'   condition = "gender"
#' )
#'

se_mean_cat <- function(data, variable, condition = NULL, strata = "zone", weight, alpha = 0.05) {
mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- occ <- nc <- ybar <- zk <- zhat <- vhat <- stand_dev <- ci <- total <- occ <- ci_per <- dummy_vars <- dummy_var <- average <- NULL

# Add row id and create dummy variables
data <- data |>
  mutate(id = row_number(), .before = 1) |>
  se_dummy(column = variable, id = "id")

dummy_vars <- names(data)[str_starts(names(data), paste0(variable, "_"))]

map(dummy_vars, function(x) {
  data |>
    filter(.data[[x]] >= 0) |>
    mutate(yk = .data[[x]]) |>
    mutate(
      occ = sum(yk == 1),
      nc = sum(.data[[weight]]),
      ybar = weighted.mean(yk, w = .data[[weight]]),
      zk = (yk - ybar) / nc, .by = all_of(condition)
    ) |>
    mutate(
      mh = n(),
      Nh = sum(.data[[weight]]),
      T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
      zhat = .data[[weight]] * zk,
      T2h = (.data[[weight]] * zk - zhat / mh)^2, .by = c(all_of(strata), all_of(condition))
    ) |>
    summarise(
      sum_T2h = sum(T2h),
      T1h = unique(T1h),
      occ = unique(occ),
      ybar = unique(ybar),
      .by = c(all_of(strata), all_of(condition))
    ) |>
    summarise(
      occ = unique(occ),
      average = unique(ybar),
      vhat = sum(T1h * sum_T2h),
      .by = all_of(condition)
    ) |>
    mutate(
      stand_dev = sqrt(vhat),
      ci = stand_dev * qnorm(1 - alpha / 2),
      dummy_var = x, .before = 1
    )
}) |>
  list_rbind() |> 
  select(dummy_var, occ, average, vhat, stand_dev, ci)
}
