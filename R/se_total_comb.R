#' Estimate Totals for All Combinations of Grouping Variables in Structural Survey
#'
#' \code{se_total_comb()} computes structural survey totals for every combination of the supplied grouping variables.
#' This wrapper function uses \code{\link[=se_total]{se_total()}} and the helper function \code{\link[=se_combn]{se_combn()}} and returns a combined tibble with results 
#' for each grouping subset, including totals across all groups. This formatting can be useful for Open Government Data platforms.
#'
#' @param data A data frame or tibble.
#' @param ... Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}..
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use.
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @return A tibble combining survey estimates for all combinations of \code{group_vars},
#'   with grouping variables converted to factors where "Total" means no grouping.
#'
#' @seealso \code{\link[=se_total]{se_total()}}, \code{\link[=se_total_map]{se_total_map()}}, \code{\link[=se_combn]{se_combn()}}.
#'
#' @import purrr
#' @import dplyr
#' @importFrom forcats fct_na_value_to_level
#' @importFrom rlang ensym ensyms syms as_label
#'
#' @export
#'
#' @examples
#' # Unquoted variables
#' se_total_comb(nhanes, strata = strata, weight = weights, gender, birth_country)
#'
#' # Programmatic use
#' wt <- "weights"
#' strata <- "strata"
#' vars <- c("gender", "birth_country")
#'
#' se_total_comb(
#'   nhanes,
#'   strata = "strata",
#'   weight = "weights",
#'   !!!rlang::syms(vars)
#' )
#'
se_total_comb <- function(data, ..., strata, weight, alpha = 0.05) {
  weight <- ensym(weight)
  strata <- if (missing(strata)) sym("zone") else ensym(strata)

  group_var_syms <- ensyms(...)
  group_var_names <- purrr::map_chr(group_var_syms, as_label)

  group_var_list <- se_combn(group_var_names)

  group_var_list |>
    map(
      \(group_vars) {
        se_total(
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


#' Generate All Combinations of Strings from a Character Vector
#'
#' \code{se_combn()} is a helper function used internally to create all possible combinations
#' of a set of variables. It is typically used for generating grouped summary tables as per Open Government Data formats.
#' @param vars A character vector of variable names.
#'
#' @returns
#' A list of character vectors, each representing a unique combination of the input strings.
#' The list includes the empty combination of length 0.
#'
#' @keywords internal
#' @importFrom purrr map list_c
#' @importFrom utils combn
#' @export
#'
#' @examples
#' vars <- letters[1:3]
#' se_combn(vars)
#'
se_combn <- function(vars) {
  map(0:length(vars), \(n) combn(vars, n, simplify = FALSE)) |>
    list_c()
}

#' Estimate Totals in Parallel for Multiple Grouping Variables in Structural Survey
#'
#' \code{se_total_map()} applies \code{\link[=se_total]{se_total()}} to a data frame for each of several grouping variables, returning a combined tibble of results.
#'
#' This wrapper function allows to efficiently compute totals and confidence intervals for each grouping variable in the structural survey data in parallel.
#'
#' @param data A data frame or tibble.
#' @param ... One or more grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#' @param alpha Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @returns A tibble with results for each grouping variable, including:
#' \describe{
#'    \item{variable}{The name of the grouping variable.}
#'    \item{value}{The value of the grouping variable.}
#'    \item{occ}{Sample size for the group.}
#'    \item{total}{Estimated total for the group.}
#'    \item{vhat, stand_dev}{Estimated variance of the total (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
#'    \item{ci, ci_per, ci_l, ci_u}{Confidence interval:  half-width (\code{ci}), percentage of the total (\code{ci_per}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
#' }
#'
#' @details
#' This function iterates over each grouping variable supplied via `...`, applies \code{se_total()} to the data grouped by that variable, and combines the results into a single tibble. The grouping variable is renamed to `value` and its name is stored in the `variable` column for clarity.
#'
#' @seealso \code{\link[=se_total]{se_total()}}, \code{\link[=se_total_comb]{se_total_comb()}}.
#' @import dplyr
#' @importFrom purrr map_chr
#' @importFrom rlang enquo enquos as_label sym syms
#' @importFrom stats qnorm
#'
#' @examples
#' # Unquoted variables
#' se_total_map(
#'   nhanes,
#'   weight = weights,
#'   strata = strata,
#'   gender, marital_status, birth_country
#' )
#' # Programmatic use and quoted variables
#' v <- c("gender", "marital_status", "birth_country")
#' se_total_map(
#'   nhanes,
#'   weight = "weights",
#'   strata = "strata",
#'   !!!rlang::syms(v)
#' )
#'
#' @export
#'
se_total_map <- function(data, ..., strata, weight, alpha = 0.05) {
  group_quos <- enquos(...)
  
  map(
    group_quos,
    ~ {
      # .x is a quosure
      col_name <- as_label(.x)
      data |>
        se_total(strata = {{ strata }}, weight = {{ weight }}, alpha = alpha, !!.x) |>
        mutate(variable = col_name, .before = 1) |>
        rename_with(~"value", all_of(col_name))
    }
  ) |>
    bind_rows()
}
