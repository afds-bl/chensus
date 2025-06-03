#' Estimate Means of Numeric Variables in Structural Survey
#'
#' \code{se_mean_num()} estimates the averages of numeric variables, the variance, and confidence
#' intervals of FSO's structural survey (Strukturerhebung / relevé structurel).
#'
#' @param data A tibble or data frame.
#' @param variable Unquoted column name of the numeric variable whose mean is to be estimated.
#'   This uses tidy evaluation, so pass the variable bare (e.g., \code{age}).
#' @param ... Optional. Unquoted grouping variables or tidyselect helpers (e.g., \code{gender}, \code{birth_country}).
#' @param strata Unquoted variable name of the strata column. Default is \code{zone}.
#' @param weight Unquoted variable name of the sampling weights column.
#' @param alpha Numeric, significance level for confidence interval calculation. Default is 0.05 (95\% CI).
#'
#' @return A tibble with the following columns:
#' \describe{
#'   \item{occ}{Sample size (number of observations) per group.}
#'   \item{<variable>}{Estimated mean of the specified numeric variable, named dynamically.}
#'   \item{vhat}{Estimated variance of the mean.}
#'   \item{stand_dev}{Standard deviation (square root of variance).}
#'   \item{ci}{Half-width of the confidence interval.}
#'   \item{ci_l}{Lower confidence interval bound.}
#'   \item{ci_u}{Upper confidence interval bound.}
#' }
#'
#' @importFrom dplyr filter mutate summarise
#' @importFrom rlang enquo enquos as_label quo_get_expr
#' @export
#'
#' @examples
#' se_mean_num(
#'   data = nhanes,
#'   variable = age,
#'   strata = strata,
#'   weight = weights,
#'   gender, birth_country
#' )
se_mean_num <- function(data, variable, ..., strata, weight, alpha = 0.05) {
  mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- nc <- ybar <- zk <- zhat <- total <- NULL
  
  # Capture quosures for tidy evaluation
  variable <- enquo(variable)
  strata <- if (missing(strata)) sym("zone") else enquo(strata)
  group_vars <- enquos(...)
  strata <- enquo(strata)
  
  # Evaluate variable as string for .data
  var_name <- as_label(quo_get_expr(variable))
  weight_name <- as_label(substitute(weight))
  
  # Safety check for numeric
  if (!is.numeric(data[[var_name]])) {
    stop(paste("Variable", var_name, "must be numeric."))
  }
  
  data |>
    filter(.data[[var_name]] >= 0) |>
    mutate(yk = .data[[var_name]]) |>
    mutate(
      occ = n(),
      nc = sum(.data[[weight_name]]),
      ybar = weighted.mean(yk, w = .data[[weight_name]]),
      zk = (yk - ybar) / nc,
      .by = c(!!!group_vars)
    ) |>
    mutate(
      mh = n(),
      Nh = sum(.data[[weight_name]]),
      T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
      zhat = .data[[weight_name]] * zk,
      T2h = (.data[[weight_name]] * zk - zhat / mh)^2,
      .by = c(!!strata, !!!group_vars)
    ) |>
    summarise(
      sum_T2h = sum(T2h),
      T1h = unique(T1h),
      occ = unique(occ),
      ybar = unique(ybar),
      .by = c(!!strata, !!!group_vars)
    ) |>
    summarise(
      occ = unique(occ),
      !!var_name := unique(ybar),
      vhat = sum(T1h * sum_T2h),
      .by = c(!!!group_vars)
    ) |>
    mutate(
      stand_dev = sqrt(vhat),
      ci = stand_dev * qnorm(1 - alpha / 2),
      ci_l = .data[[var_name]] - ci,
      ci_u = .data[[var_name]] + ci
    ) |> 
    arrange(!!!group_vars)
}

#' Estimate Proportions of Categorical Variables in Structural Survey
#'
#' \code{se_mean_cat()} estimates the proportion of and confidence intervals for each level of a categorical variable
#'of FSO's structural survey, 
#' by first converting it to dummy variables and then computing statistics within strata and optional groupings.
#'
#' @param data A tibble or data frame.
#' @param variable Unquoted column name of the categorical variable whose proportion is to be estimated.
#'   This uses tidy evaluation, so pass the variable bare (e.g., \code{interview_lang}).
#' @param ... Optional. Unquoted grouping variables or tidyselect helpers (e.g., \code{gender}, \code{birth_country}).
#' @param condition [Deprecated] Use \code{group_vars} instead. Unquoted variable names for grouping.
#' @param strata Unquoted variable name of the strata column. Default is \code{zone}.
#' @param weight Unquoted variable name of the sampling weights column.
#' @param alpha Numeric, significance level for confidence interval calculation. Default is 0.05 (95\% CI).
#'
#' @return A tibble with the following columns:
#' \describe{
#'   \item{occ}{Sample size (number of observations) per group.}
#'   \item{prop}{Estimated proportion of the specified categorical variable}
#'   \item{vhat}{Estimated variance of the mean.}
#'   \item{stand_dev}{Standard deviation (square root of variance).}
#'   \item{ci}{Half-width of the confidence interval.}
#'   \item{ci_l}{Lower confidence interval bound.}
#'   \item{ci_u}{Upper confidence interval bound.}
#' }
#' @importFrom dplyr select arrange filter mutate summarise group_by ungroup across all_of
#' @importFrom rlang enquo as_label quo_get_expr sym
#' @importFrom tidyr pivot_wider
#' @importFrom stringr str_starts
#' @importFrom purrr map list_rbind
#' @export
#'
#' @examples
#' se_mean_cat(
#'   data = nhanes,
#'   variable = interview_lang,
#'   group_vars = birth_country,
#'   strata = strata,
#'   weight = weights
#' )
#'
se_mean_cat <- function(data, variable, ..., condition = NULL, strata, weight, alpha = 0.05) {
  mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- nc <- ybar <- zk <- zhat <- total <- occ <- dummy_vars <- category_level <- prop <- NULL
  
  variable <- enquo(variable)
  strata <- if (missing(strata)) sym("zone") else enquo(strata)
  weight <- enquo(weight)
  group_vars <- enquos(...)
  
  # Deprecated `condition`
  if (!is.null(condition)) {
    warning("Argument `condition` is deprecated. Use `group_vars` instead.", call. = FALSE)
    if (length(group_vars) == 0) {
      group_vars <- enquos(!!!condition)
    }
  }
  
  # Turn categorical variable into dummy variables
  var_name <- as_label(quo_get_expr(variable))
  
  data <- se_dummy(data, !!variable)
  
  dummy_vars <- names(data)[stringr::str_starts(names(data), paste0(var_name, "_"))]
  
  map(dummy_vars, function(x) {
    data |>
      filter(.data[[x]] >= 0) |>
      mutate(yk = .data[[x]]) |>
      mutate(
        occ = sum(yk == 1),
        nc = sum(!!weight),
        ybar = weighted.mean(yk, w = !!weight),
        zk = (yk - ybar) / nc,
        .by = c(!!!group_vars)
      ) |>
      mutate(
        mh = n(),
        Nh = sum(!!weight),
        T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
        zhat = !!weight * zk,
        T2h = (!!weight * zk - zhat / mh)^2,
        .by = c(!!strata, !!!group_vars)
      ) |>
      summarise(
        sum_T2h = sum(T2h),
        T1h = unique(T1h),
        occ = unique(occ),
        ybar = unique(ybar),
        .by = c(!!strata, !!!group_vars)
      ) |>
      summarise(
        occ = unique(occ),
        prop = unique(ybar),
        vhat = sum(T1h * sum_T2h),
        .by = c(!!!group_vars)
      ) |>
      mutate(
        stand_dev = sqrt(vhat),
        ci = stand_dev * qnorm(1 - alpha / 2),
        ci_l = prop - ci,
        ci_u = prop + ci,
        category_level = x,
        .before = 1
      )
  }) |>
    list_rbind() |>
    select(category_level, !!!group_vars, occ, prop, vhat, stand_dev, starts_with("ci")) |> 
    arrange(!!!group_vars)
}
