<!-- README.md is generated from README.Rmd. Please edit that file -->

# chensus <img src="man/figures/logo.png" align="right" width="10%" />

[![R-CMD-check](https://github.com/afds-bl/chensus/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/afds-bl/chensus/actions/workflows/R-CMD-check.yaml)
[![License: GPL
v3](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

`chensus` estimates population frequencies, means, proportions and
confidence intervals from surveys conducted by the Federal Statistical
Office (FSO):

- structural survey: *Strukturerhebung* (SE) / *relevé structurel* (RS),
- mobility and transport survey: *Mikrozensus Mobilität und Verkehr*
  (MZMV) / *Microrecensement mobilité et transports* (MRMT).

`chensus` implements closed-form formulas of confidence interval
estimates as outlined in FSO’s methodological reports for the
[structural
survey](https://www.bfs.admin.ch/bfs/en/home/services/research/methodological-reports.assetdetail.11187024.html)
and [mobility and transport
survey](https://www.bfs.admin.ch/bfs/fr/home/statistiques/mobilite-transports/enquetes/mzmv.assetdetail.24266729.html).
For mathematical details, see the [Method
vignette](articles/method.html).

# Installation

``` r
# Install from GitHub
remotes::install_github("afds-bl/chensus")
```

# Usage

As an example, we use the [National Health and Nutrition Examination
Survey (NHANES)
dataset](https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_I.htm) for the
period 2015-2016 (more with `?nhanes`). Its structure is similar to FSO
survey data in that it contains `strata` and `weights` columns and
demographic features such as `gender` and `household_size`.

## Structural survey (*Strukturerhebung* / *relevé structurel*)

Here we estimate the male and female populations:

``` r
library(chensus)

se_estimate_total(
  data = nhanes,
  weight = "weights",
  strata = "strata",
  condition = "gender"
)
# A tibble: 2 × 7
  gender      total    vhat   occ stand_dev       ci ci_per
  <fct>       <dbl>   <dbl> <int>     <dbl>    <dbl>  <dbl>
1 Male   146242153. 7.52e12  4592  2741918. 5374060.   3.67
2 Female 151475830. 7.30e12  4715  2702304. 5296418.   3.50
```

``` r
library(chensus)

se_estimate_mean(
  data = nhanes, 
  variable = "household_size", 
  var_type = "num", 
  weight = "weights")
   occ  average        vhat  stand_dev         ci
1 9307 3.449383 0.000533299 0.02309327 0.04526197
```

## Mobility and Transport Survey (MZMV/MRMT)

Here we estimate the annual household and family incomes:

``` r
library(chensus)

mzmv_estimate_mean(
  data = nhanes,
  variable = c("annual_household_income", "annual_family_income"),
  weight = "weights"
)
                 variable   nc    wmean        ci
1 annual_household_income 9307 11.77473 0.2393474
2    annual_family_income 9307 11.42304 0.2413382
```

We can also use the `mzmv_estimate_mean_map()` function with a set of
conditions:

``` r
library(chensus)

variable <- c("annual_household_income", "annual_family_income")
condition <- c("gender", "interview_lang")

mzmv_estimate_mean_map(
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

# License

Distributed under the GPL-3 License. See `LICENSE` for more information.

# Contact

[Souad Guemghar](mailto:souad.guemghar@bl.ch)

# Acknowledgments

This package is an extension of
[vhatbfs](https://github.com/gibonet/vhatbfs) by Sandro Burri, a package
to estimate the confidence intervals of *Strukturerhebung* / *relevé
structurel*. Many thanks Sandro for the great work and support!

# Citation

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
