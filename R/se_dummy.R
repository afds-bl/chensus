#' Create Joint Dummy Variables from Multiple Categorical Columns
#'
#' \code{se_dummy} is an internal helper function used to generate dummy (0/1) variables
#' based on the combinations of multiple categorical variables. It is primarily used by
#' \code{se_prop()} to support grouped dummy encoding.
#'
#' @param data A data frame or tibble.
#' @param ... One or more categorical columns (unquoted or quoted) whose combinations will be
#'   used to generate joint dummy variables.
#' @param sep A character string to separate combined category names (default is "_").
#'
#' @return A tibble including all original data columns and additional dummy columns
#' representing all unique combinations of the provided categorical variables.
#'
#' @importFrom tidyr unite
#' @importFrom fastDummies dummy_cols
#' @importFrom rlang enquos
#'
#' @export
#' 
#' @keywords internal
#'
#' @examples
#' df <- tibble::tibble(gender = c("male", "female"), country = c("US", "Other"))
#' se_dummy(df, gender, country)
#'
se_dummy <- function(data, ..., sep = "_") {
  prefix <- "joint"
  columns_quo <- rlang::enquos(...)

  data <- unite(
    data,
    col = {{ prefix }},
    !!!columns_quo,
    sep = sep,
    remove = FALSE
  )

  data <- dummy_cols(
    data,
    select_columns = prefix,
    remove_first_dummy = FALSE,
    remove_selected_columns = TRUE
  )

  return(data)
}
