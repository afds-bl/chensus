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
#'
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

#' Generic OGD wrapper for survey estimation functions
#'
#' @param data A data frame or tibble.
#' @param core_fun The core estimation function to use, one of \code{se_mean}, \code{se_total}, \code{se_prop}.
#' @param ... Grouping variables (unquoted or programmatic).
#' @param strata Stratification variable (unquoted or programmatic).
#' @param weight Sampling weights variable (unquoted or programmatic).
#' @param alpha Significance level for confidence intervals.
#' @param variable (Optional) Variable to estimate mean for (only needed for se_mean).
#' @param show_internal Show internal estimates of variance, standard deviation (and percent confidence interval for \code{se_total()}).
#' Hidden by default.
#'
#' @return A tibble with estimates for all combinations of grouping variables.
#'
#' @import dplyr
#' @importFrom purrr map map_chr list_rbind
#' @importFrom rlang ensym ensyms syms as_label
#' @importFrom forcats fct_na_value_to_level
#'
se_ogd_wrapper <- function(data, core_fun, ..., strata, weight, alpha = 0.05, variable = NULL, show_internal = FALSE) {
  weight <- ensym(weight)
  group_var_syms <- ensyms(...)
  group_var_names <- map_chr(group_var_syms, as_label)
  group_var_list <- se_combn(group_var_names)

  if (is.null(variable)) {
    # For se_total and se_prop
    results <- group_var_list |>
      map(
        \(group_vars) {
          core_fun(
            data,
            strata = !!strata,
            weight = !!weight,
            alpha = alpha,
            !!!syms(group_vars)
          )
        }
      )
  } else {
    # For se_mean (requires 'variable' argument)
    results <- group_var_list |>
      map(
        \(group_vars) {
          core_fun(
            data,
            variable = !!variable,
            strata = !!strata,
            weight = !!weight,
            alpha = alpha,
            !!!syms(group_vars)
          )
        }
      )
  }

  output <- results |>
    list_rbind() |>
    relocate(all_of(group_var_names)) |>
    mutate(
      across(
        all_of(group_var_names),
        \(v) fct_na_value_to_level(as.character(v), "Total")
      )
    )
  
  if (!show_internal) {
    to_drop <- c("stand_dev", "vhat")
    if (identical(core_fun, se_total)) {
      to_drop <- c(to_drop, "ci_per")
    }
    output <- output |> select(-any_of(to_drop))
  }
  
  return(output)
}

#' Estimate Totals for All Combinations of Grouping Variables (OGD Format)
#'
#' \code{se_total_ogd} estimates survey totals for every combination of the supplied grouping variables,
#' using \code{se_total} internally and returning results in a format suitable for Open Government Data (OGD).
#' The output includes totals for each combination of grouping variables, as well as for the overall population.
#'
#' @param data A data frame or tibble.
#' @param ... Grouping variables (unquoted or programmatic).
#' @param strata Stratification variable (unquoted or programmatic). Defaults to "zone" if omitted.
#' @param weight Sampling weights variable (unquoted or programmatic).
#' @param alpha Significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @return A tibble with survey estimates for all combinations of grouping variables.
#'   Grouping variables are converted to factors with "Total" representing the overall group.
#'
#' @seealso \code{\link{se_prop_ogd}}, \code{\link{se_mean_ogd}}, \code{\link{se_ogd_wrapper}}, \code{\link{se_total}}
#'
#' @export
#'
#' @examples
#' # Unquoted variables
#' se_total_ogd(nhanes, strata = strata, weight = weights, gender, birth_country)
#'
#' # Programmatic use
#' wt <- "weights"
#' vars <- c("gender", "birth_country")
#' se_total_ogd(nhanes, strata = strata, weight = !!rlang::sym(wt), !!!rlang::syms(vars))
#'
se_total_ogd <- function(data, ..., strata, weight, alpha = 0.05) {
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  se_ogd_wrapper(data, se_total, ..., strata = {{ strata }}, weight = {{ weight }}, alpha = alpha)
}

#' Estimate Proportions for All Combinations of Grouping Variables (OGD Format)
#'
#' \code{se_prop_ogd} estimates survey proportions for every combination of the supplied grouping variables,
#' using \code{se_prop} internally and returning results in a format suitable for Open Government Data (OGD).
#' The output includes proportions for each combination of grouping variables, as well as for the overall population.
#'
#' @param data A data frame or tibble.
#' @param ... Grouping variables (unquoted or programmatic).
#' @param strata Stratification variable (unquoted or programmatic). Defaults to "zone" if omitted.
#' @param weight Sampling weights variable (unquoted or programmatic).
#' @param alpha Significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @return A tibble with survey proportion estimates for all combinations of grouping variables.
#'   Grouping variables are converted to factors with "Total" representing the overall group.
#'
#' @seealso \code{\link{se_total_ogd}}, \code{\link{se_mean_ogd}}, \code{\link{se_ogd_wrapper}}, \code{\link{se_prop}}
#'
#' @export
#'
#' @examples
#' # Unquoted variables
#' se_prop_ogd(nhanes, strata = strata, weight = weights, gender, birth_country)
#'
#' # Programmatic use
#' wt <- "weights"
#' vars <- c("gender", "birth_country")
#' se_prop_ogd(nhanes, strata = strata, weight = !!rlang::sym(wt), !!!rlang::syms(vars))
#'
se_prop_ogd <- function(data, ..., strata, weight, alpha = 0.05) {
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  se_ogd_wrapper(data, se_prop, ..., strata = {{ strata }}, weight = {{ weight }}, alpha = alpha)
}

#' Estimate Totals and Proportions for All Combinations of Grouping Variables (OGD Format)
#'
#' \code{se_total_prop_ogd} estimates totals and proportions for each combination
#' of grouping variables using \code{se_total_prop}, returning results in a format compatible with Open Government Data (OGD) standards.
#' along with stratification and weighting.
#'
#' @param data A data frame or tibble containing the survey data.
#' @param ... Grouping variables (unquoted or programmatic) to compute combinations of totals and proportions.
#' @param strata Stratification variable (unquoted or programmatic). Defaults to \code{"zone"} if omitted.
#' @param weight Sampling weight variable (unquoted or programmatic).
#' @param alpha Significance level for confidence intervals. Default is 0.05 (for 95\% CI).
#'
#' @return A tibble with totals and proportions for all combinations of the specified grouping variables.
#' The output includes confidence intervals and handles missing values by representing them as "Total".
#'
#' @seealso \code{\link{se_total_prop}}, \code{\link{se_ogd_wrapper}}, \code{\link{se_total_ogd}}, \code{\link{se_prop_ogd}}
#'
#' @export
#'
#' @examples
#' # With unquoted variables
#' se_total_prop_ogd(nhanes, gender, birth_country, strata = strata, weight = weights)
#'
#' # Programmatic usage
#' vars <- c("gender", "birth_country")
#' wt <- "weights"
#' se_total_prop_ogd(nhanes, !!!rlang::syms(vars), strata = strata, weight = !!rlang::sym(wt))
#'
se_total_prop_ogd <- function(data, ..., strata, weight, alpha = 0.05) {
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  se_ogd_wrapper(data, se_total_prop, ..., strata = {{ strata }}, weight = {{ weight }}, alpha = alpha)
}

#' Estimate Means for All Combinations of Grouping Variables (OGD Format)
#'
#' \code{se_mean_ogd} estimates survey means of a continuous variable for every combination of the supplied grouping variables,
#' using \code{se_mean} internally and returning results in a format suitable for Open Government Data (OGD).
#' The output includes means for each combination of grouping variables, as well as for the overall population.
#'
#' @param data A data frame or tibble.
#' @param variable Variable to estimate the mean for (unquoted or programmatic).
#' @param ... Grouping variables (unquoted or programmatic).
#' @param strata Stratification variable (unquoted or programmatic). Defaults to "zone" if omitted.
#' @param weight Sampling weights variable (unquoted or programmatic).
#' @param alpha Significance level for confidence intervals. Default is 0.05 (95\% CI).
#'
#' @return A tibble with survey mean estimates for all combinations of grouping variables.
#'   Grouping variables are converted to factors with "Total" representing the overall group.
#'
#' @seealso \code{\link{se_total_ogd}}, \code{\link{se_prop_ogd}}, \code{\link{se_ogd_wrapper}}, \code{\link{se_mean}}
#'
#' @export
#'
#' @examples
#' # Unquoted variables
#' se_mean_ogd(nhanes, variable = household_size, strata = strata, weight = weights, gender)
#'
#' # Programmatic use
#' var <- "household_size"
#' wt <- "weights"
#' vars <- "gender"
#' se_mean_ogd(
#'   nhanes,
#'   variable = !!rlang::sym(var),
#'   strata = strata,
#'   weight = !!rlang::sym(wt),
#'   !!!rlang::syms(vars)
#' )
#'
se_mean_ogd <- function(data, variable, ..., strata, weight, alpha = 0.05) {
  strata <- if (missing(strata)) sym("zone") else ensym(strata)
  variable <- ensym(variable)
  se_ogd_wrapper(data, se_mean, ..., strata = {{ strata }}, weight = {{ weight }}, alpha = alpha, variable = variable)
}
