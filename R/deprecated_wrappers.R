#' @rdname chensus-deprecated
#' @export
se_estimate_total <- function(...) {
  .Deprecated("se_total", package = "chensus")
  se_total(...)
}

#' @rdname chensus-deprecated
#' @export
se_estimate_mean <- function(...) {
  .Deprecated("se_mean", package = "chensus")
  se_mean(...)
}
se_mean_num <- function(...) {
  .Deprecated("se_mean", package = "chensus")
  se_mean(...) 
}
se_mean_cat <- function (...) {
  .Deprecated("se_prop", package = "chensus")
  se_prop(...) 
}

#' @rdname chensus-deprecated
#' @export
mzmv_estimate_mean <- function(...) {
  .Deprecated("mzmv_mean", package = "chensus")
  mzmv_mean(...)
}

#' @rdname chensus-deprecated
#' @export
mzmv_estimate_mean_map <- function(...) {
  .Deprecated("mzmv_mean_map", package = "chensus")
  mzmv_mean_map(...)
}
