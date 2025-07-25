% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/se_mean.R
\name{se_mean}
\alias{se_mean}
\title{Estimate Means of Numeric Variables in Structural Survey}
\usage{
se_mean(data, variable, ..., strata, weight, alpha = 0.05)
}
\arguments{
\item{data}{A data frame or tibble.}

\item{variable}{Unquoted or quoted name of the numeric variable whose mean is to be estimated.
Programmatic usage (e.g., using \code{!!sym()}) is supported.}

\item{...}{Optional grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.}

\item{strata}{Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.}

\item{weight}{Unquoted or quoted name of the sampling weights column. For programmatic use
with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.}

\item{alpha}{Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).}
}
\value{
A tibble with columns:
\describe{
  \item{occ}{Sample size (number of observations) per group.}
  \item{<variable>}{Estimated mean of the specified numeric variable, named dynamically.}
  \item{vhat, stand_dev}{Estimated variance of the mean (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
  \item{ci, ci_l, ci_u}{Confidence interval: half-width (\code{ci}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
}
}
\description{
\code{se_mean()} estimates the means of numeric variables along with variance
and confidence intervals for FSO's structural survey.
}
\examples{
# Direct column references (unquoted)
se_mean(
  data = nhanes,
  variable = age,
  strata = strata,
  weight = weights,
  gender, birth_country
)

# Quoted column names
se_mean(
  data = nhanes,
  variable = "age", 
  strata = "strata", 
  weight = "weights", 
  gender, birth_country
)

# Programmatic use with strings
v <- "age"
wt <- "weights"
vars <- c("gender", "birth_country")
se_mean(
  data = nhanes,
  variable = !!rlang::sym(v),
  strata = strata,
  weight = !!rlang::sym(wt),
  !!!rlang::syms(vars)
)

}
\seealso{
\code{\link[=se_prop]{se_prop()}}
}
