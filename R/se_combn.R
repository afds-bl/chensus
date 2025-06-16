#' Generate All Combinations of Strings from a Character Vector
#' 
#' \code{se_combn()} is a helper function used internally to create all possible combinations
#' of a set of variables. It is typically used for generating grouped summary tables as per Open Government Data formats.
#' #' @param vars A character vector of variable names.
#'
#' @returns
#' A list of character vectors, each representing a unique combination of the input strings.
#' The list includes the empty combination of length 0.
#'
#' @keywords internal
#' @importFrom purrr map list_c
#' @export
#' 
#' @examples
#' se_combn(c("gender", "birth_country"))
#'
se_combn <- function(vars) {
  map(0:length(vars), \(n) combn(vars, n, simplify = FALSE)) |>
    list_c()
}
