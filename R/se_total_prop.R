#' Create a Table with Total and Proportion Estimates for Categorical Variables in Structural Survey
#'
#'  \code{se_total_prop} is a wrapper function for \code{se_total()} and \code{se_prop()} which estimates totals and proportions for categorical variables.
#'
#' @param data A data frame or tibble.
#' @param ... Optional grouping variables (unquoted).
#' @param strata The name of the strata variable (default is "zone").
#' @param weight The name of the weight variable.
#' @param alpha Significance level for confidence intervals. Default is 0.05.
#'
#' @returns A tibble with joined total and proportion estimates.
#'
#' @importFrom dplyr select full_join
#' @importFrom rlang ensym enquos syms
#' @importFrom purrr map_chr
#' @export
#' 
#' @seealso \code{\link[=se_total]{se_total()}}, \code{\link[=se_prop]{se_prop()}}.
#'
#' @examples
#' se_total_prop(
#'   data = nhanes,
#'   interview_lang,
#'   gender,
#'   birth_country,
#'   strata = strata,
#'   weight = weights
#' )
#'
se_total_prop <- function(data, ..., strata, weight, alpha = 0.05) {
  group_quo <- enquos(...)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  weight <- ensym(weight)

  group_vars <- map_chr(group_quo, as_label)

  # Estimate proportions
  res_p <- data |>
    se_prop(
      !!!group_quo,
      strata = !!strata,
      weight = !!weight,
      alpha = alpha
    ) |>
    select(-stand_dev, -vhat)

  # Estimate totals
  res_t <- data |>
    se_total(
      !!!group_quo,
      strata = !!strata,
      weight = !!weight,
      alpha = alpha
    ) |>
    select(-stand_dev, -vhat, -ci_per)

  # Join and mask
  full_join(
    res_t,
    res_p,
    by = c(group_vars, "occ"),
    suffix = c("_total", "_prop")
  ) 
}
