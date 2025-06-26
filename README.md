<!-- README.md is generated from README.Rmd. Please edit that file -->

# chensus <img src="man/figures/logo.png" align="right" width="10%" />

[![R-CMD-check](https://github.com/afds-bl/chensus/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/afds-bl/chensus/actions/workflows/R-CMD-check.yaml)
![Lifecycle:
active](https://img.shields.io/badge/lifecycle-active-brightgreen.svg)
[![License: GPL
v3](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

`chensus` is an R package for estimating populations from surveys
conducted by the Swiss Federal Statistical Office (FSO), specifically:

- structural survey: *Strukturerhebung* (SE) / *relevé structurel* (RS),
- mobility and transport survey: *Mikrozensus Mobilität und Verkehr*
  (MZMV) / *Microrecensement mobilité et transports* (MRMT).

It implements closed-form formulas for confidence intervals as described
in the FSO’s methodological reports for the [structural
survey](https://www.bfs.admin.ch/bfs/en/home/services/research/methodological-reports.assetdetail.11187024.html)
and [mobility and transport
survey](https://www.bfs.admin.ch/bfs/fr/home/statistiques/mobilite-transports/enquetes/mzmv.assetdetail.24266729.html).
For mathematical details, see the [Method
vignette](articles/Method.html).

## Installation

You can install the development version from GitHub with:

``` r
remotes::install_github("afds-bl/chensus")
```

## Usage

Refer to the [package vignette](articles/chensus.html) for detailed
examples and use cases.

### Structural survey

Estimate total population by gender:

``` r
library(chensus)

se_total(
  data = nhanes,
  gender,
  weight = weights,
  strata = strata
)
# A tibble: 2 × 9
  gender   occ      total    vhat stand_dev       ci ci_per       ci_l      ci_u
  <chr>  <int>      <dbl>   <dbl>     <dbl>    <dbl>  <dbl>      <dbl>     <dbl>
1 Female  5079 161922446. 7.82e12  2795884. 5479833.   3.38 156442613.    1.67e8
2 Male    4892 154558598. 7.90e12  2810039. 5507576.   3.56 149051022.    1.60e8
```

Estimate average household size (numeric variable):

``` r
se_mean(
  data = nhanes,
  variable = household_size,
  weight = weights,
  strata = strata
)
# A tibble: 1 × 7
    occ household_size     vhat stand_dev     ci  ci_l  ci_u
  <int>          <dbl>    <dbl>     <dbl>  <dbl> <dbl> <dbl>
1  9971           3.46 0.000495    0.0222 0.0436  3.42  3.51
```

Estimate population proportions by gender (categorical variable):

``` r
se_prop(
  data = nhanes,
  gender,
  weight = weights,
  strata = strata
)
# A tibble: 2 × 8
  gender   occ  prop      vhat stand_dev     ci  ci_l  ci_u
  <chr>  <int> <dbl>     <dbl>     <dbl>  <dbl> <dbl> <dbl>
1 Female  5079 0.512 0.0000520   0.00721 0.0141 0.498 0.526
2 Male    4892 0.488 0.0000520   0.00721 0.0141 0.474 0.502
```

### Mobility and Transport Survey

Estimate average annual household and family incomes:

``` r
mzmv_mean(
  data = nhanes,
  annual_household_income, annual_family_income,
  weight = weights
)
# A tibble: 2 × 4
  variable                  occ wmean    ci
  <chr>                   <int> <dbl> <dbl>
1 annual_household_income  9626  11.9 0.240
2 annual_family_income     9642  11.5 0.245
```

Estimate average annual household and family incomes by gender:

``` r
mzmv_mean_map(
  data = nhanes,
  variable = c("annual_household_income", "annual_family_income"),
  gender,
  weight = weights
)
# A tibble: 4 × 6
  variable                group_vars group_vars_value   occ wmean    ci
  <chr>                   <chr>      <fct>            <int> <dbl> <dbl>
1 annual_household_income gender     Female            4906  11.8 0.350
2 annual_household_income gender     Male              4720  12.0 0.328
3 annual_family_income    gender     Female            4917  11.5 0.358
4 annual_family_income    gender     Male              4725  11.6 0.334
```

## Documentation

The package includes the following vignettes:

- [chensus](articles/chensus.html) gives detailed examples of how to use
  the package.
- [Method](articles/Method.html) details the mathematical background of
  the confidence interval estimates.
- [nhanes](articles/nhanes.html) inspects the example data set.

## License

Distributed under the GPL-3 License. See `LICENSE` for more information.

## Contact

[Souad Guemghar](mailto:souad.guemghar@bl.ch)

Amt für Daten und Statistik, Basel-Landschaft.

## Acknowledgments

This package is an extension of
[vhatbfs](https://github.com/gibonet/vhatbfs) by Sandro Burri, which
estimates the confidence intervals of totals for the structural survey.
Many thanks to Sandro for the foundational work and support.

This package uses data derived from the National Health and Nutrition
Examination Survey (NHANES), provided by the CDC/NCHS and available at
<https://www.cdc.gov/nchs/nhanes/>. Data are adapted for educational or
demonstration purposes and are not suitable for research unless
downloaded directly from the official source.

## Citation

``` r
utils::citation("chensus")
```

    To cite 'chensus' in publications, please use:

      Guemghar, S. (2025). chensus: Estimate Totals, Means, Proportions and
      Confidence Intervals of the Federal Statistic Office's Surveys. R
      package version 2.0.0. Amt für Daten und Statistik, Basel-Landschaft.
      https://github.com/afds-bl/chensus

    A BibTeX entry for LaTeX users is

      @Manual{,
        title = {{chensus}: Estimate Totals, Means, Proportions and Confidence Intervals of the Federal Statistic Office's Surveys},
        author = {{Guemghar} and {S.}},
        organization = {Amt für Daten und Statistik, Basel-Landschaft},
        note = {R package version 2.0.0},
        year = {2025},
        url = {https://github.com/afds-bl/chensus},
      }

## Code of Conduct

The `chensus` project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
