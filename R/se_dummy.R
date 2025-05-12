#' Create dummy variables
#'
#' @param data Tibble
#' @param column Character string, name of variable to dummify
#' @param id Character string, name of unique identifier ID column
#'
#' @return Tibble composed of original tibble and newly created dummy variables
#'
#' @import tidyr
#' @import dplyr
#'
#' @export
#'
#' @examples
#' data <- data.frame(
#' id = 1:5,
#' category = c("A", "B", "A", "C", "B")
#' )
#' se_dummy(data, "category", "id")
#'
se_dummy <- function(data, column, id) {
  dummy_value <- NULL
  # Create dummy variables
  dummy_data <- data |>
    dplyr::select(all_of(column), all_of(id)) |>
    dplyr::mutate(dummy_value = 1L) |>
    tidyr::pivot_wider(
      names_from = {{ column }}, values_from = dummy_value,
      values_fill = list(dummy_value = 0), names_prefix = ""
    ) |>
    # Prefix with original variable name
    dplyr::rename_with(\(x) paste(column, x, sep = "_"), -id)
  data <- dplyr::full_join(data, dummy_data, by = id)

  return(data)
}
