#' Format Table with Totals and Proportions for a Categorical Variable
#'
#' This function estimates proportions for a categorical variable grouped by optional variables, computes totals,
#' joins both estimates, removes unnecessary columns.
#'
#' @param data A data frame or tibble.
#' @param ... Optional grouping variables (unquoted).
#' @param strata The name of the strata variable (default is "zone").
#' @param weight The name of the weight variable.
#' @param alpha Significance level for confidence intervals. Default is 0.05.
#'
#' @returns A tibble with proportions and totals joined, masked as necessary.
#'
#' @importFrom dplyr select full_join
#' @importFrom rlang ensym enquos syms
#' @importFrom purrr map_chr
#' @export
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
