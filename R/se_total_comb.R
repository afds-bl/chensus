#' Calculate Estimates for All Combinations of Grouping Variables in Structural Survey
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
#'   with grouping variables converted to factors where "Total" means .
#'
#' @seealso \code{\link[=se_total]{se_total()}}, \code{\link[=se_total_map]{se_total_map()}}
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
se_total_comb <- function(data, ..., strata, weight) {
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
