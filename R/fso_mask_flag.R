#' Classify Estimate Reliability and Apply Confidentiality Masking
#'
#' \code{fso_flag_mask} applies Swiss Federal Statistical Office (FSO) reliability rules for survey estimates,
#' based on the number of observations (\code{occ}). It flags low reliability estimates and masks them when sample size is too small
#' (\code{occ <= 4}).
#'
#' @param data A data frame or tibble.
#' @param lang A character string for the language of the estimate reliability description, one of "de", "fr", "it", "en".
#' Defaults to German if omitted.
#'
#' @returns A tibble containing the original data with masked estimates when \code{occ <= 4} and one additional column:
#' \describe{
#'   \item{obs_status}{character column classifying reliability of estimates.}
#' }
#'
#' @details
#' FSO estimate reliability criteria:
#' \describe{
#'   \item{\code{occ <= 4: }}{No estimate (confidential).}
#'   \item{\code{occ <= 49: }}{Estimate of low reliability.}
#'   \item{\code{occ > 49: }}{Reliable estimate.}
#' }
#'
#' @import dplyr
#'
#' @export
#'
#' @examples
#' df <- data.frame(occ = c(3, 10, 60), mean_income = c(4000, 4200, 4500))
#' fso_flag_mask(df)
#'
fso_flag_mask <- function(data, lang = c("de", "fr", "it", "en")) {
  lang <- match.arg(lang)

  # Define language-specific messages
  messages <- list(
    de = c(
      confidential = "Kein Sch\u00e4tzwert (vertraulich)",
      low = "Sch\u00e4tzwert bedingt verl\u00e4sslich",
      reliable = "Sch\u00e4tzwert verl\u00e4sslich"
    ),
    fr = c(
      confidential = "Pas d'estimation (confidentiel)",
      low = "Estimation peu fiable",
      reliable = "Estimation fiable"
    ),
    it = c(
      confidential = "Nessuna stima (confidenziale)",
      low = "Stima poco affidabile",
      reliable = "Stima affidabile"
    ),
    en = c(
      confidential = "No estimate (confidential)",
      low = "Estimate of low reliability",
      reliable = "Reliable estimate"
    )
  )

  if (!"occ" %in% names(data)) {
    stop("Input data frame must contain an 'occ' column.")
  }

  occ_pos <- match("occ", names(data))
  numeric_cols <- data |>
    select((all_of(occ_pos)):last_col()) |>
    select(where(is.numeric)) |>
    names()

  data <- data |>
    mutate(
      obs_status = case_when(
        occ <= 4 ~ messages[[lang]]["confidential"],
        occ <= 49 ~ messages[[lang]]["low"],
        .default = messages[[lang]]["reliable"]
      )
    ) |>
    mutate(
      across(
        all_of(numeric_cols),
        \(x) if_else(occ <= 4, NA, x)
      )
    )

  return(data)
}
