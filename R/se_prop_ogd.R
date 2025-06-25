#' Estimate Proportions for All Combinations of Grouping Variables in Structural Survey (OGD Format)
#'
#' \code{se_prop_ogd()} is a wrapper function that computes proportions and associated confidence intervals
#' for every combination of the supplied grouping variables. It uses \code{\link[=se_prop]{se_prop()}} internally
#' and combines results for each combination, including totals across all groups. The output is formatted
#' for Open Government Data (OGD) platforms, with grouping variables as factors and "Total" used for
#' the overall group.
#'
#' @param data A data frame or tibble.
#' @param ... Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country})
#'   or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use,
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @return A tibble combining proportion estimates for all combinations of grouping variables,
#'   including totals across all groups. Grouping variables are converted to factors with "Total"
#'   representing the overall group. The output includes:
#' \describe{
#'   \item{occ}{Sample size (number of observations) per group.}
#'   \item{prop}{Estimated proportion of the specified categorical variable in the corresponding group.}
#'   \item{vhat, stand_dev}{Estimated variance of the mean (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
#'   \item{ci, ci_l, ci_u}{Confidence interval: half-width (\code{ci}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
#' }
#'
#' @seealso \code{\link[=se_prop]{se_prop()}}, \code{\link[=se_total_ogd]{se_total_ogd()}}, \code{\link[=se_combn]{se_combn()}}.
#'
#' @import dplyr
#' @importFrom rlang ensym ensyms syms as_label
#' @importFrom purrr map map_chr list_rbind
#' @importFrom forcats fct_na_value_to_level
#'
#' @export
#'
#' @examples
#' # Unquoted variables
#' se_prop_ogd(
#'   data = nhanes,
#'   strata = strata,
#'   weight = weights,
#'   gender, birth_country
#' )
#'
#' # Programmatic use
#' wt <- "weights"
#' vars <- c("gender", "birth_country")
#' se_prop_ogd(
#'   data = nhanes,
#'   strata = strata,
#'   weight = !!rlang::sym(wt),
#'   !!!rlang::syms(vars)
#' )
#'
se_prop_ogd <- function(data, ..., strata, weight, alpha = 0.05) {
  weight <- ensym(weight)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  
  group_var_syms <- ensyms(...)
  group_var_names <- map_chr(group_var_syms, as_label)
  
  group_var_list <- se_combn(group_var_names)
  
  group_var_list |>
    map(
      \(group_vars) {
        se_prop(
          data,
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