% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/se_total.R
\name{se_total}
\alias{se_total}
\title{Estimate Totals of Structural Survey}
\usage{
se_total(data, ..., strata, weight, alpha = 0.05)
}
\arguments{
\item{data}{A data frame or tibble.}

\item{...}{Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.}

\item{strata}{Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.}

\item{weight}{Unquoted or quoted name of the sampling weights column. For programmatic use
with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.}

\item{alpha}{Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).}
}
\value{
A tibble with total estimates for all grouping column combinations, including:
\describe{
  \item{<variable>}{Value of the grouping variables passed in \code{...}.}
   \item{occ}{number of observations in survey sample.}
   \item{total}{population estimate.}
   \item{vhat, stand_dev}{Estimated variance of the total (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
  \item{ci, ci_per, ci_l, ci_u}{Confidence interval:  half-width (\code{ci}), percentage of the total (\code{ci_per}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
 }
}
\description{
\code{se_total()} estimates the totals  and confidence intervals of FSO structural surveys.
}
\details{
The \code{condition} argument has been deprecated and is no longer supported.
Please use \code{...} to pass grouping variables either unquoted or programmatically using \code{rlang}:

* Interactive use:

  \code{se_total(data, weight = my_weight, group1, group2)}

* Programmatic use:

  \code{weight_var <- "my_weight"}

  \code{group_vars <- c("group1", "group2")}

  \code{se_total(data, weight = !!rlang::sym(weight_var), !!!rlang::syms(group_vars))}
}
\examples{
# One grouping variable
se_total(
  data = nhanes,
  strata = strata,
  weight = weights,
  gender
)
# Multiple grouping variables
se_total(
  data = nhanes,
  strata = strata,
  weight = weights,
  gender, marital_status, birth_country
)
# Programmatic use and quoted variables
v <- c("gender", "marital_status", "birth_country")
se_total(
  nhanes,
  weight = "weights",
  strata = "strata",
  !!!rlang::syms(v)
)

}
\seealso{
\code{\link[=se_total_map]{se_total_map()}}, \code{\link[=se_total_ogd]{se_total_ogd()}}.
}
