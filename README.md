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
remotes::install_github("afds-bl/chensus")
```

## Usage

### Structural survey (SE/RS)

Estimate population totals by gender:

``` r
library(chensus)

se_total(
  data = nhanes,
  weight = "weights",
  strata = "strata",
  group_vars = "gender"
)
# A tibble: 2 × 7
  gender   occ      total    vhat stand_dev       ci ci_per
  <fct>  <int>      <dbl>   <dbl>     <dbl>    <dbl>  <dbl>
1 Male    4892 154558598. 7.90e12  2810039. 5507576.   3.56
2 Female  5079 161922446. 7.82e12  2795884. 5479833.   3.38
```

Estimate average household size:

``` r
se_mean_num(
  data = nhanes,
  variable = "household_size",
  weight = "weights",
  strata = "strata"
)
# A tibble: 1 × 5
    occ average     vhat stand_dev     ci
  <int>   <dbl>    <dbl>     <dbl>  <dbl>
1  9971    3.46 0.000495    0.0222 0.0436
```

Estimate population proportions by household size:

``` r
se_mean_cat(
  data = nhanes,
  variable = "household_size",
  weight = "weights",
  strata = "strata"
)
# A tibble: 7 × 6
  dummy_var          occ average       vhat stand_dev      ci
  <chr>            <int>   <dbl>      <dbl>     <dbl>   <dbl>
1 household_size_2  1723  0.254  0.0000499    0.00706 0.0138 
2 household_size_1   828  0.103  0.0000209    0.00457 0.00896
3 household_size_5  1672  0.134  0.0000180    0.00424 0.00831
4 household_size_7   974  0.0613 0.00000592   0.00243 0.00477
5 household_size_3  1719  0.175  0.0000297    0.00545 0.0107 
6 household_size_4  2061  0.204  0.0000327    0.00572 0.0112 
7 household_size_6   994  0.0696 0.00000826   0.00287 0.00563
```

### Mobility and Transport Survey (MZMV/MRMT)

Estimate average annual household and family incomes:

``` r
mzmv_mean(
  data = nhanes,
  variable = c("annual_household_income", "annual_family_income"),
  weight = "weights"
)
# A tibble: 2 × 4
  variable                   nc wmean    ci
  <chr>                   <int> <dbl> <dbl>
1 annual_household_income  9626  11.9 0.240
2 annual_family_income     9642  11.5 0.245
```

Estimate by group (e.g., gender, interview language):

``` r
mzmv_mean_map(
  data = nhanes,
  variable = c("annual_household_income", "annual_family_income"),
  group_vars = c("gender", "interview_lang"),
  weight = "weights"
)
# A tibble: 8 × 6
  variable                group_vars     group_vars_value    nc wmean    ci
  <chr>                   <chr>          <fct>            <int> <dbl> <dbl>
1 annual_household_income gender         Male              4720  12.0 0.328
2 annual_household_income gender         Female            4906  11.8 0.350
3 annual_family_income    gender         Male              4725  11.6 0.334
4 annual_family_income    gender         Female            4917  11.5 0.358
5 annual_household_income interview_lang English           8310  11.8 0.241
6 annual_household_income interview_lang Spanish           1316  12.0 1.07 
7 annual_family_income    interview_lang English           8326  11.5 0.247
8 annual_family_income    interview_lang Spanish           1316  11.6 1.07 
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
