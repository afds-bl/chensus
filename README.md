<!-- README.md is generated from README.Rmd. Please edit that file -->

# chensus <img src="man/figures/logo.png" align="right" width="10%" />

[![R-CMD-check](https://github.com/afds-bl/chensus/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/afds-bl/chensus/actions/workflows/R-CMD-check.yaml)
[![License: GPL
v3](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

`chensus` is an R package for estimating populations from surveys
conducted by the Swiss Federal Statistical Office (FSO), sepcificially:

- structural survey: *Strukturerhebung* (SE) / *relevé structurel* (RS),
- mobility and transport survey: *Mikrozensus Mobilität und Verkehr*
  (MZMV) / *Microrecensement mobilité et transports* (MRMT).

It implements closed-form formulas for confidence intervals as described
in the FSO’s methodological reports for the [structural
survey](https://www.bfs.admin.ch/bfs/en/home/services/research/methodological-reports.assetdetail.11187024.html)
and [mobility and transport
survey](https://www.bfs.admin.ch/bfs/fr/home/statistiques/mobilite-transports/enquetes/mzmv.assetdetail.24266729.html).
For mathematical details, see the [Method
vignette](articles/method.html).

## Installation

You can install the development version from GitHub with:

``` r
# Install from GitHub
remotes::install_github("afds-bl/chensus")
```

## Usage

### Structural survey (SE/RS)

Estimate population totals by gender

``` r
library(chensus)

se_total(
  data = nhanes,
  weight = "weights",
  strata = "strata",
  condition = "gender"
)
# A tibble: 2 × 7
  gender   occ      total    vhat stand_dev       ci ci_per
  <fct>  <int>      <dbl>   <dbl>     <dbl>    <dbl>  <dbl>
1 Male    4592 146242153. 7.52e12  2741918. 5374060.   3.67
2 Female  4715 151475830. 7.30e12  2702304. 5296418.   3.50
```

Estimate average household size

``` r
se_mean_num(
  data = nhanes,
  variable = "household_size",
  weight = "weights",
  strata = "strata"
)
   occ  average        vhat  stand_dev         ci
1 9307 3.449383 0.000533299 0.02309327 0.04526197
```

Estimate population proportions by household size

``` r
library(chensus)

se_mean_cat(
  data = nhanes,
  variable = "household_size",
  weight = "weights",
  strata = "strata"
)
         dummy_var  occ    average         vhat   stand_dev          ci
1 household_size_2 1630 0.25710445 5.331753e-05 0.007301886 0.014311433
2 household_size_1  807 0.10700246 2.302751e-05 0.004798698 0.009405276
3 household_size_5 1554 0.13231214 1.900636e-05 0.004359628 0.008544714
4 household_size_7  917 0.06200017 6.480589e-06 0.002545700 0.004989480
5 household_size_3 1588 0.16994437 3.050700e-05 0.005523314 0.010825497
6 household_size_4 1914 0.20352104 3.509434e-05 0.005924048 0.011610920
7 household_size_6  897 0.06811537 8.825002e-06 0.002970690 0.005822446
```

### Mobility and Transport Survey (MZMV/MRMT)

Estimate average annual household and family incomes

``` r
library(chensus)

mzmv_mean(
  data = nhanes,
  variable = c("annual_household_income", "annual_family_income"),
  weight = "weights"
)
                 variable   nc    wmean        ci
1 annual_household_income 9307 11.77473 0.2393474
2    annual_family_income 9307 11.42304 0.2413382
```

Estimate by group (e.g., gender, interview language)

``` r
library(chensus)

variable <- c("annual_household_income", "annual_family_income")
condition <- c("gender", "interview_lang")

mzmv_mean_map(
  data = nhanes,
  variable = variable,
  condition = condition,
  weight = "weights"
)
# A tibble: 8 × 6
  variable                condition      condition_value    nc wmean    ci
  <chr>                   <chr>          <fct>           <int> <dbl> <dbl>
1 annual_household_income gender         Male             4592  11.9 0.331
2 annual_household_income gender         Female           4715  11.6 0.346
3 annual_family_income    gender         Male             4592  11.5 0.330
4 annual_family_income    gender         Female           4715  11.3 0.352
5 annual_household_income interview_lang English          8131  11.7 0.233
6 annual_household_income interview_lang Spanish          1176  13.2 1.24 
7 annual_family_income    interview_lang English          8131  11.3 0.235
8 annual_family_income    interview_lang Spanish          1176  12.8 1.25 
```

## Documentation

- `?nhanes`: inspect the example dataset
- `vignette("Method")`: mathematical background
- `?se_total`, `?mzmv_mean`, etc.: function documentation

## License

Distributed under the GPL-3 License. See `LICENSE` for more information.

## Contact

[Souad Guemghar](mailto:souad.guemghar@bl.ch)

Amt für Daten und Statistik, Basel-Landschaft

## Acknowledgments

This package is an extension of
[vhatbfs](https://github.com/gibonet/vhatbfs) by Sandro Burri, which
estimates the confidence intervals of totals for the structural survey.
Many thanks to Sandro for the foundational work and support.

## Citation

``` r
utils::citation("chensus")
```

    To cite 'chensus' in publications, please use:

      Guemghar, S. (2025). chensus: Estimate Totals, Averages and
      Confidence Intervals of the Federal Statistic Office's Surveys. R
      package version 1.0.0. Amt für Daten und Statistik, Basel-Landschaft.
      https://github.com/afds-bl/chensus

    A BibTeX entry for LaTeX users is

      @Manual{,
        title = {{chensus}: Estimate Totals, Averages and Confidence Intervals of the Federal Statistic Office's Surveys},
        author = {Souad Guemghar},
        organization = {Amt für Daten und Statistik, Basel-Landschaft},
        note = {R package version 1.0.0},
        year = {2025},
        url = {https://github.com/afds-bl/chensus},
      }
