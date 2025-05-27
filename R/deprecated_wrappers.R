#' @rdname chensus-deprecated
#' @export
se_estimate_total <- function(...) {
  .Deprecated("se_total", package = "chensus")
  se_total(...)
}

#' @rdname chensus-deprecated
#' @export
se_estimate_mean <- function(...) {
  .Deprecated("se_mean_num", package = "chensus")
  se_mean_num(...)
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

#' @rdname chensus-deprecated
#' @export
mzmv_estimate_prop <- function(...) {
  .Deprecated("mzmv_prop", package = "chensus")
  mzmv_prop(...)
}

