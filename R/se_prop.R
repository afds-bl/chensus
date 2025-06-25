#' Estimate Proportions of Categorical Variables in Structural Survey
#'
#' \code{se_prop()} estimates the proportions and confidence intervals for each level of one or multiple categorical variables
#' of FSO's structural survey, by first converting columns into dummy variables and then estimating proportions and confidence intervals.
#'
#' @param data A data frame or tibble.
#' @param ... Categorical variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @returns A tibble with proportion estimates for all grouping column combinations, including:
#' \describe{
#'    \item{occ}{Sample size (number of observations) per group.}
#'    \item{prop}{Estimated proportion of the specified categorical variable in the corrresponding group.}
#'    \item{vhat, stand_dev}{Estimated variance of the mean (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
#'    \item{ci, ci_l, ci_u}{Confidence interval: half-width (\code{ci}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
#' }
#'
#' @import dplyr
#' @importFrom rlang sym ensym enquos as_label as_name
#' @importFrom tidyr separate_wider_delim
#' @importFrom stringr str_starts str_remove str_replace_all
#' @importFrom purrr map map_chr list_rbind
#' @importFrom stats weighted.mean qnorm
#' @export
#'
#' @examples
#' # Direct column references (unquoted)
#' se_prop(
#'   data = nhanes,
#'   interview_lang,
#'   birth_country,
#'   strata = strata,
#'   weight = weights
#' )
#'
#' # Quoted column names
#' se_prop(
#'   data = nhanes,
#'   "interview_lang",
#'   gender,
#'   "birth_country",
#'   strata = "strata",
#'   weight = weights,
#' )
#'
#' # Programmatic use with strings
#' wt <- "weights"
#' vars <- c("interview_lang", "gender", "birth_country")
#' se_prop(
#'   data = nhanes,
#'   strata = strata,
#'   weight = !!rlang::sym(wt),
#'   !!!rlang::syms(vars)
#' )
#'
se_prop <- function(data, ..., strata, weight, alpha = 0.05) {
  group_vars <- enquos(...)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  weight <- ensym(weight)

  group_var_names <- map_chr(group_vars, as_name)

  data <- data |>
    mutate(across(all_of(group_var_names), \(x) str_replace_all(as.character(x), "_", ".")))

  data <- se_dummy(data, !!!group_vars)

  dummy_vars <- names(data)[str_starts(names(data), "joint_")]

  results <- map(dummy_vars, function(x) {
    data |>
      filter(.data[[x]] >= 0) |>
      mutate(yk = .data[[x]]) |>
      mutate(
        occ = sum(yk == 1),
        nc = sum(!!weight),
        ybar = weighted.mean(yk, w = !!weight),
        zk = (yk - ybar) / nc
      ) |>
      mutate(
        mh = n(),
        Nh = sum(!!weight),
        T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
        zhat = !!weight * zk,
        T2h = (!!weight * zk - zhat / mh)^2,
        .by = c(!!strata)
      ) |>
      summarise(
        sum_T2h = sum(T2h),
        T1h = unique(T1h),
        occ = unique(occ),
        ybar = unique(ybar),
        .by = c(!!strata)
      ) |>
      summarise(
        occ = unique(occ),
        prop = unique(ybar),
        vhat = sum(T1h * sum_T2h)
      ) |>
      mutate(
        stand_dev = sqrt(vhat),
        ci = stand_dev * qnorm(1 - alpha / 2),
        ci_l = prop - ci,
        ci_u = prop + ci,
        output = str_remove(x, "joint_"),
        .before = 1
      )
  }) |>
    list_rbind()

  if (length(group_var_names) > 0) {
    results <- results |>
      select(output, occ, prop, vhat, stand_dev, starts_with("ci")) |>
      separate_wider_delim(output, delim = "_", names = group_var_names)
  } else {
    results <- results |>
      select(occ, prop, vhat, stand_dev, starts_with("ci"))
  }

  return(results)
}
