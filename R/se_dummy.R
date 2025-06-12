#' Create Dummy Variables from a Categorical Column
#'
#' \code{se_dummy()} is a helper function used by \code{\link[=se_mean_cat]{se_mean_cat()}}. It generates dummy (0/1) variables for each level of a categorical variable.
#'
#' @param data A data frame or tibble.
#' @param column The name of the categorical column to convert into dummy variables. Can be provided unquoted, quoted, or programmatically using \code{!!sym(col_name)}.
#'
#' @returns A tibble containing the original data with one additional dummy column for each level of the specified categorical variable.
#'
#' @importFrom tidyr pivot_wider
#' @importFrom rlang as_label enquo
#' @importFrom dplyr select mutate left_join relocate select
#'
#' @export
#'
#' @examples
#' se_dummy(mtcars, cyl)
#'
se_dummy <- function(data, column) {
  column <- ensym(column)
  col_name <- as_label(column)

  dummy_data <- data |>
    select(all_of(col_name)) |>
    mutate(dummy_value = 1L, row_id___ = row_number()) |>
    pivot_wider(
      names_from = {{ column }},
      values_from = dummy_value,
      values_fill = list(dummy_value = 0),
      names_prefix = paste0(col_name, "_")
    )

  data <- data |>
    mutate(row_id___ = row_number()) |>
    left_join(dummy_data, by = "row_id___") |>
    select(-row_id___) |>
    relocate(starts_with(col_name), .after = all_of(col_name))

  return(data)
}
