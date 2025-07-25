% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/se_total.R
\name{se_total_map}
\alias{se_total_map}
\title{Estimate Totals in Parallel for Multiple Grouping Variables in Structural Survey}
\usage{
se_total_map(data, ..., strata, weight, alpha = 0.05)
}
\arguments{
\item{data}{A data frame or tibble.}

\item{...}{One or more grouping variables. Can be passed unquoted (e.g., \code{gender}, \code{birth_country}) or programmatically using \code{!!!syms(c("gender", "birth_country"))}.}

\item{strata}{Unquoted or quoted name of the strata column. Defaults to \code{zone} if omitted.}

\item{weight}{Unquoted or quoted name of the sampling weights column. For programmatic use
with a string variable (e.g., \code{wt <- "weights"}), use \code{!!sym(wt)} in the function call.}

\item{alpha}{Numeric significance level for confidence intervals. Default is 0.05 (95\% CI).}
}
\value{
A tibble with results for each grouping variable, including:
\describe{
   \item{variable}{The name of the grouping variable.}
   \item{value}{The value of the grouping variable.}
   \item{occ}{Sample size for the group.}
   \item{total}{Estimated total for the group.}
   \item{vhat, stand_dev}{Estimated variance of the total (\code{vhat}) and its standard deviation (\code{stand_dev}, square root of the variance).}
   \item{ci, ci_per, ci_l, ci_u}{Confidence interval:  half-width (\code{ci}), percentage of the total (\code{ci_per}), lower (\code{ci_l}) and upper (\code{ci_u}) bounds.}
}
}
\description{
\code{se_total_map()} applies \code{\link[=se_total]{se_total()}} to a data frame for each of several grouping variables, returning a combined tibble of results.
}
\details{
This wrapper function allows to efficiently compute totals and confidence intervals for each grouping variable in the structural survey data in parallel.


This function iterates over each grouping variable supplied via \code{...}, applies \code{se_total()} to the data grouped by that variable, 
and combines the results into a single tibble. The grouping variable is renamed to \code{value} and its name is stored in the \code{variable} column for clarity.
}
\examples{
# Unquoted variables
se_total_map(
  nhanes,
  weight = weights,
  strata = strata,
  gender, marital_status, birth_country
)
# Programmatic use and quoted variables
v <- c("gender", "marital_status", "birth_country")
se_total_map(
  nhanes,
  weight = "weights",
  strata = "strata",
  !!!rlang::syms(v)
)

}
\seealso{
\code{\link[=se_total]{se_total()}}, \code{\link[=se_total_ogd]{se_total_ogd()}}.
}
