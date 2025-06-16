#' Calculate Survey Estimates for All Combinations of Grouping Variables in Structural Survey
#'
#' \code{se_total_comb()} computes structural survey totals for every combination of the supplied grouping variables.
#' It uses \code{se_total()} and \code{se_combn()} internally and returns a combined tibble with results for each grouping subset,
#' including totals across all groups. This formatting can be useful to publish on Open Government Data platforms.
#'
#' @param data A data frame or tibble.
#' @param ... Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}..
#' @param strata Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.
#' @param weight Unquoted or quoted name of the sampling weights column. For programmatic use.
#'   with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.
#'
#' @return A tibble combining survey estimates for all combinations of \code{group_vars},
#'   with grouping variables converted to factors where missing values are replaced by "Total".
#'
#' @seealso \code{\link[=se_total]{se_total()}}, \code{\link[=se_total_map]{se_total_map()}}
#'
#' @import purrr
#' @import dplyr
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
#'   !!!syms(vars)
#' )
#'
se_total_comb <- function(data, ..., strata, weight) {
  group_var_syms <- rlang::ensyms(...)
  group_var_names <- purrr::map_chr(group_var_syms, rlang::as_label)

  group_var_list <- se_combn(group_var_names)

  group_var_list |>
    map(
      \(group_vars) {
        se_total(
          data,
          strata = {{ strata }},
          weight = {{ weight }},
          !!!syms(group_vars)
        )
      }
    ) |>
    list_rbind() |>
    relocate(all_of(group_var_names)) |>
    mutate(
      across(
        all_of(group_var_names),
        \(v) fct_na_value_to_level(v, "Total")
      )
    )
}
