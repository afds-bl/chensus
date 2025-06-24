#' Estimate Averages of Numeric Variables in Structural Survey
#'
#' \code{se_mean()} estimates the averages of numeric variables along with variance
#' and confidence intervals for FSO's structural survey.
#'
#' @param data A data frame or tibble.
#' @param variable Unquoted or quoted name of the numeric variable whose mean is to be estimated.
#'   Programmatic usage (e.g., using \code{!!sym()}) is supported.
#' @param ... Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @returns A tibble with columns:
#' \describe{
#'   \item{occ}{Sample size (number of observations) per group.}
#'   \item{<variable>}{Estimated mean of the specified numeric variable, named dynamically.}
#'   \item{vhat, stand_dev}{Estimated variance of the mean (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
#'   \item{ci, ci_l, ci_u}{Confidence interval: half-width (\code{ci}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
#' }
#'
#' @import dplyr
#' @importFrom rlang ensym enquos as_label sym ensym
#' @importFrom stats weighted.mean qnorm
#' @export
#'
#' @seealso \code{\link[=se_prop]{se_prop()}}
#' @examples
#' # Direct column references (unquoted)
#' se_mean(
#'   data = nhanes,
#'   variable = age,
#'   strata = strata,
#'   weight = weights,
#'   gender, birth_country
#' )
#'
#' # Quoted column names
#' se_mean(
#'   data = nhanes,
#'   variable = "age", 
#'   strata = "strata", 
#'   weight = "weights", 
#'   gender, birth_country
#' )
#'
#' # Programmatic use with strings
#' v <- "age"
#' wt <- "weights"
#' vars <- c("gender", "birth_country")
#' se_mean(
#'   data = nhanes,
#'   variable = !!rlang::sym(v),
#'   strata = strata,
#'   weight = !!rlang::sym(wt),
#'   !!!rlang::syms(vars)
#' )
#'
se_mean <- function(data, variable, ..., strata, weight, alpha = 0.05) {
  variable <- ensym(variable)
  group_vars <- enquos(...)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  weight <- ensym(weight)
  var_name <- as_label(variable)

  # Safety check for numeric
  if (!is.numeric(data[[var_name]])) {
    stop(paste("Variable", var_name, "must be numeric."))
  }

  data |>
    filter(!!variable >= 0) |>
    mutate(yk = !!variable) |>
    mutate(
      occ = n(),
      nc = sum(!!weight),
      ybar = weighted.mean(yk, w = !!weight),
      zk = (yk - ybar) / nc,
      .by = c(!!!group_vars)
    ) |>
    mutate(
      mh = n(),
      Nh = sum(!!weight),
      T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
      zhat = !!weight * zk,
      T2h = (!!weight * zk - zhat / mh)^2,
      .by = c(!!strata, !!!group_vars)
    ) |>
    summarise(
      sum_T2h = sum(T2h),
      T1h = unique(T1h),
      occ = unique(occ),
      ybar = unique(ybar),
      .by = c(!!strata, !!!group_vars)
    ) |>
    summarise(
      occ = unique(occ),
      {{ variable }} := unique(ybar),
      vhat = sum(T1h * sum_T2h),
      .by = c(!!!group_vars)
    ) |>
    mutate(
      stand_dev = sqrt(vhat),
      ci = stand_dev * qnorm(1 - alpha / 2),
      ci_l = !!variable - ci,
      ci_u = !!variable + ci
    ) |>
    arrange(!!!group_vars)
}
