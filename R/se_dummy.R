#' Create Dummy Variables from a Categorical Variable
#'
#' @param data A data frame or tibble.
#' @param column Unquoted categorical column name to dummify.
#'
#' @returns A tibble with the original data and newly created dummy variables added.
#'
#' @importFrom tidyr pivot_wider
#' @importFrom rlang as_label enquo
#' @importFrom dplyr select mutate left_join relocate select
#'
#' @export
#'
#' @examples
#' data <- data.frame(
#' id = 1:5,
#' category = c("A", "B", "A", "C", "B")
#' )
#' se_dummy(data, category)
#'
se_dummy <- function(data, column) {
  column <- ensym(column)
  col_name <- as_label(column)
  
  # Dummify column
  dummy_data <- data |>
    select(all_of(col_name)) |> 
    mutate(dummy_value = 1L, row_id___ = row_number()) |>
    pivot_wider(
      names_from = {{ column }},
      values_from = dummy_value,
      values_fill = list(dummy_value = 0),
      names_prefix = paste0(col_name, "_")
    )
  
  # Join dummy columns back to original data
  data <- data |>
    mutate(row_id___ = row_number()) |>
    left_join(dummy_data, by = "row_id___") |>
    select(-row_id___) |> 
    relocate(starts_with(col_name), .after = all_of(col_name))
  
  return(data)
}
