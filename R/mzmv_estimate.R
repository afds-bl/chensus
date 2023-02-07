#' Estimate means from mobility survey
#'
#' \code{mzmv_estimate_mean()} estimates the mean frequencies and confidence
#' intervals of BFS/OFS mobility surveys.
#'
#' @param object Vector of character strings, to be estimated
#' @param data Tibble
#' @param weight Character string, name of the column containing the
#' weights
#' @param cf Double, correction factor of the confidence interval, supplied by BFS/OFS
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @returns Tibble (number of rows is length of \code{object}) with the following columns:
#' \itemize{
#' \item{\code{id}: }{estimated item}
#' \item{\code{nc}: }{number of survey responses}
#' \item{\code{wmean}: }{weighted mean estimate}
#' \item{\code{ci}: }{confidence interval estimate}
#' }
#'
#' @examples
#' # We can use the nhanes dataset as an example even if it only contains population data
#' library(dplyr)
#' # Estimate two means
#' mzmv_estimate_mean(
#'   c("annual_household_income", "annual_family_income"),
#'   data = nhanes,
#'   weight = "weights",
#'   alpha = 0.1
#' )
#' # With conditions
#' c("gender", "interview_lang") %>%
#'   purrr::set_names() %>%
#'   purrr::map(~ mzmv_estimate_mean(
#'     object = c("annual_household_income", "annual_family_income"),
#'     data = nhanes %>% group_by(.data[[.x]]), weight = "weights"
#'   ))
#'
#' @import dplyr
#'
#' @export
#'
mzmv_estimate_mean <- function(object, data, weight, cf = 1.14, alpha = 0.05) {
  object %>%
    purrr::set_names() %>% # Output is a list whose elements are named using object
    purrr::map(~ data %>%
      filter(.data[[.x]] >= 0) %>%
      summarise(
        nc = n(),
        wmean = weighted.mean(x = .data[[.x]], w = .data[[weight]]),
        ci = cf * sqrt(sum(.data[[weight]] * (.data[[.x]] - wmean)^2) / (sum(.data[[weight]]) - 1) / n()) * qnorm(1 - alpha / 2)
      )) %>%
    purrr::list_rbind(names_to = "id") # Convert into a table
}

#' Estimate proportions from mobility survey
#'
#' \code{mzmv_estimate_prop} estimates the proportions and confidence intervals of BFS/OFS mobility survey data
#'
#' @import dplyr
#'
#' @export
#'
mzmv_estimate_prop <- function(data, object, weight, cf = 1.14, alpha = 0.05) {
  data %>%
    summarise(
      p = sum(.data[[weight]] * .data[[object]]) / sum(.data[[weight]]),
      ci = cf * sqrt(p * (1 - p) / n()) * qnorm(1 - alpha / 2)
    )
}
