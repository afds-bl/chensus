#' Summarise population survey
#'
#' \code{se_summarise()} stratifies the number of true occurrences and
#' estimated populations in population surveys provided by the the Bundesamt
#' für Statistik / Office Fédéral de la Statistique.
#'
#' @param data Tibble
#' @param weight Character string, name of the column containing the
#' weights
#' @param strata Vector of character strings, names of the columns containing the
#' strata
#' @param mh_col Character string, desired column name of number of true occurrences per stratum
#' @param Nh_col Character string, desired column name of estimated population per stratum
#'
#' @returns Tibble \code{data} augmented with columns \code{mh_col} and \code{Nhcol}
#'
#' @examples
#' # One strata variable
#' library(dplyr)
#' se_summarise(nhanes, weight = "weights", strata = "strata") |>
#'   glimpse()
#' # Two strata variables
#' se_summarise(nhanes,
#'   weight = "weights", strata = c("strata", "gender"),
#'   mh_col = "mhc", Nh_col = "Nhc"
#' ) |>
#'   select(weights, strata, gender, mhc, Nhc) |>
#'   group_by(strata, gender) |>
#'   slice_sample(n = 2) |>
#'   head(10)
#'
#' @import dplyr
#'
#' @export

se_summarise <- function(
    data,
    weight,
    strata,
    mh_col = "mh",
    Nh_col = "Nh"
    ) {
  data |>
    group_by(across(all_of(strata))) |>
    add_count(name = {{ mh_col }}) |>
    add_count(wt = .data[[weight]], name = {{ Nh_col }}) |>
    ungroup()
}
