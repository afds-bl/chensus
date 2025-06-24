#' Estimate Averages of Numeric Variables for All Combinations of Grouping Variables in Structural Survey
#'
#' \code{se_mean_ogd()} computes structural survey means for every combination of the supplied grouping variables.
#' This wrapper function uses \code{\link[=se_mean]{se_mean()}} and the helper function \code{\link[=se_combn]{se_combn()}} and returns a combined tibble with results
#' for each grouping subset, including means across all groups. This formatting can be useful for Open Government Data platforms.
#'
#' @param data A data frame or tibble.
#' @param variable Unquoted or quoted name of the numeric variable whose mean is to be estimated.
#'   Programmatic usage (e.g., using \code{!!sym()}) is supported.
#' @param ... Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}..
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use.
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @return A tibble combining survey estimates for all combinations of \code{group_vars},
#'   with grouping variables converted to factors where "Total" means no grouping.
#'
#' @seealso \code{\link[=se_mean]{se_mean()}}, \code{\link[=se_combn]{se_combn()}}.
#'
#' @import purrr
#' @import dplyr
#' @importFrom forcats fct_na_value_to_level
#' @importFrom rlang ensym ensyms syms as_label
#'
#' @export
#'
#' @examples
#' se_mean_ogd(
#'   nhanes,
#'   variable = household_size,
#'   strata = strata,
#'   weight = weights,
#'   gender, interview_lang
#' )
#'
se_mean_ogd <- function(data, variable, ..., strata, weight, alpha = 0.05) {
  weight <- ensym(weight)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)

  group_var_syms <- ensyms(...)
  group_var_names <- map_chr(group_var_syms, as_label)

  group_var_list <- se_combn(group_var_names)

  group_var_list |>
    map(
      \(group_vars) {
        se_mean(
          data,
          variable = {{ variable }},
          strata = {{ strata }},
          weight = {{ weight }},
          alpha = alpha,
          !!!syms(group_vars)
        )
      }
    ) |>
    list_rbind() |>
    relocate(all_of(group_var_names)) |>
    mutate(
      across(
        all_of(group_var_names),
        \(v) {
          fct_na_value_to_level(as.character(v), "Total")
        }
      )
    )
}
