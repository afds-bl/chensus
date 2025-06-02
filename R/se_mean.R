#' Estimate means of numeric variables in structural survey
#'
#' \code{se_mean_num()} estimates the averages of numeric variables,  the variance and confidence
#' intervals of FSO's structural survey (Strukturerhebung / relevé structurel).
#'
#' @param data A tibble or data frame.
#' @param variable Unquoted column name of the numeric variable whose mean is to be estimated.
#'   This uses tidy evaluation, so pass the variable bare (e.g., \code{age}).
#' @param group_vars Optional. Unquoted variable names or tidyselect helpers specifying grouping variables
#'   (e.g., \code{c(gender, birth_country)}).
#' @param condition [Deprecated] Use \code{group_vars} instead. Unquoted variable names for grouping.
#' @param strata Unquoted variable name of the strata/zone column.
#' @param weight Unquoted variable name of the sampling weights column.
#' @param alpha Numeric, significance level for confidence interval calculation; default is 0.05 (95\% CI).
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
#' @importFrom dplyr filter mutate summarise group_by ungroup across all_of
#' @importFrom rlang enquo as_label quo_get_expr
#' @export
#'
#' @examples
#' se_mean_num(
#'   data = nhanes,
#'   variable = age,
#'   strata = strata,
#'   weight = weights,
#'   group_vars = c(gender, birth_country)
#' )
se_mean_num <- function(data, variable, group_vars = NULL, condition = NULL, strata = "zone", weight, alpha = 0.05) {
  mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- occ <- nc <- ybar <- zk <- zhat <- vhat <- stand_dev <- ci <- total <- occ <- ci_l <- ci_u <- NULL

  # Capture quosures for tidy evaluation
  variable <- enquo(variable)
  group_vars <- enquos(group_vars)
  strata <- enquo(strata)
  
  # Evaluate variable as string for .data
  var_name <- as_label(quo_get_expr(variable))
  weight_name <- as_label(substitute(weight))
  
  # Safety check for numeric
  if (!is.numeric(data[[var_name]])) {
    stop(paste("Variable", var_name, "must be numeric."))
  }
  
  data %>%
    filter(.data[[var_name]] >= 0) %>%
    mutate(yk = .data[[var_name]]) %>%
    mutate(
      occ = n(),
      nc = sum(.data[[weight_name]]),
      ybar = weighted.mean(yk, w = .data[[weight_name]]),
      zk = (yk - ybar) / nc,
      .by = c(!!!group_vars)
    ) %>%
    mutate(
      mh = n(),
      Nh = sum(.data[[weight_name]]),
      T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
      zhat = .data[[weight_name]] * zk,
      T2h = (.data[[weight_name]] * zk - zhat / mh)^2,
      .by = c(!!strata, !!!group_vars)
    ) %>%
    summarise(
      sum_T2h = sum(T2h),
      T1h = unique(T1h),
      occ = unique(occ),
      ybar = unique(ybar),
      .by = c(!!strata, !!!group_vars)
    ) %>%
    summarise(
      occ = unique(occ),
      !!var_name := unique(ybar),
      vhat = sum(T1h * sum_T2h),
      .by = c(!!!group_vars)
    ) %>%
    mutate(
      stand_dev = sqrt(vhat),
      ci = stand_dev * qnorm(1 - alpha / 2),
      ci_l = .data[[var_name]] - ci,
      ci_u = .data[[var_name]] + ci
    )
}

#' Estimate means of categorical variables in structural survey
#'
#' \code{se_mean_cat()} estimates the proportion of categorical variables along with the variance and confidence
#' intervals of FSO's structural survey (Strukturerhebung / relevé structurel).
#'
#' @param data Tibble
#' @param variable Character string, name of the categorical variable whose proportion we would like
#' to estimate
#' @param group_vars A character vector of grouping variables.
#' @param condition [Deprecated] Use `group_vars` instead. A character vector of grouping variables.
#' @param strata Character string, name of the column containing the
#' strata/zones
#' @param weight Character string, name of the column containing the
#' weights
#' @param alpha Double, significance level. Default 0.05 for 95\% confidence interval.
#'
#' @return Tibble, with the following columns:
#'  \itemize{
#'  \item \code{occ}: true frequency in survey sample
#'  \item \code{average}: estimated mean
#'  \item \code{vhat}: estimated variance
#'  \item \code{stand_dev}: standard deviation
#'  \item \code{ci}: absolute confidence interval
#'  }
#' @import dplyr
#' @import stringr
#' @import purrr
#' @export
#'
#' @examples
#' se_mean_cat(
#'   data = nhanes,
#'   variable = "interview_lang",
#'   strata = "strata",
#'   weight = "weights",
#'   group_vars = "birth_country"
#' )
#'
se_mean_cat <- function(data, variable, group_vars = NULL, condition = NULL, strata = "zone", weight, alpha = 0.05) {
  mh <- Nh <- T1h <- T2h <- sum_T2h <- yk <- occ <- nc <- ybar <- zk <- zhat <- vhat <- stand_dev <- ci <- total <- occ <- ci_per <- dummy_vars <- dummy_var <- average <- NULL

  if (!is.null(condition)) {
    warning("Argument `condition` is deprecated. Please use `group_vars` instead.", call. = FALSE)
    if (is.null(group_vars)) {
      group_vars <- condition
    }
  }

  # Add row id and create dummy variables
  data <- data %>%
    mutate(id = row_number(), .before = 1) %>%
    se_dummy(column = variable, id = "id")

  dummy_vars <- names(data)[str_starts(names(data), paste0(variable, "_"))]

  map(dummy_vars, function(x) {
    data %>%
      filter(.data[[x]] >= 0) %>%
      mutate(yk = .data[[x]]) %>%
      mutate(
        occ = sum(yk == 1),
        nc = sum(.data[[weight]]),
        ybar = weighted.mean(yk, w = .data[[weight]]),
        zk = (yk - ybar) / nc, .by = all_of(group_vars)
      ) %>%
      mutate(
        mh = n(),
        Nh = sum(.data[[weight]]),
        T1h = ifelse(mh != 1, mh / (mh - 1) * (1 - mh / Nh), 0),
        zhat = .data[[weight]] * zk,
        T2h = (.data[[weight]] * zk - zhat / mh)^2, .by = c(all_of(strata), all_of(group_vars))
      ) %>%
      summarise(
        sum_T2h = sum(T2h),
        T1h = unique(T1h),
        occ = unique(occ),
        ybar = unique(ybar),
        .by = c(all_of(strata), all_of(group_vars))
      ) %>%
      summarise(
        occ = unique(occ),
        average = unique(ybar),
        vhat = sum(T1h * sum_T2h),
        .by = all_of(group_vars)
      ) %>%
      mutate(
        stand_dev = sqrt(vhat),
        ci = stand_dev * qnorm(1 - alpha / 2),
        dummy_var = x, .before = 1
      )
  }) %>%
    list_rbind() %>%
    select(dummy_var, all_of(group_vars), occ, average, vhat, stand_dev, ci)
}
