#' Summarise population survey
#'
#' \code{summarise_pop_cens()} stratifies the number of true occurrences and
#' estimated populations in population surveys provided by the the Bundesamt
#' für Statistik / Office Fédéral de la Statistique.
#'
#' @param data Tibble
#' @param weight_colname Character string, name of the column containing the
#' weights
#' @param strata_variable Vector of haracter strings, names of the columns containing the
#' strata
#' @param mh_col Character string, desired column name of number of true occurrences per stratum
#' @param Nh_col Character string, desired column name of estimated population per stratum
#'
#' @returns Tibble \code{data} augmented with columns \code{mh_col} and \code{Nhcol}
#'
#' @examples
#' summarise_pop_cens(nhanes, weight_colname = "weights", strata_variable = "strata") %>%
#'   glimpse()
#'
#' @import dplyr
#'
#' @export

summarise_pop_cens <- function(data, weight_colname, strata_variable,
                               mh_col = "mh", Nh_col = "Nh") {
  data %>%
    group_by(across(all_of(strata_variable))) %>%
    summarise(
      {{ mh_col }} := n(), # number of participants per stratum
      {{ Nh_col }} := sum(.data[[weight_colname]]) # Total of weights per stratum
    ) %>%
    left_join(data, ., by = strata_variable)
}
