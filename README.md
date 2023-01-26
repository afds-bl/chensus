
- <a href="#bfsestimates" id="toc-bfsestimates">BFSestimates</a>
- <a href="#installation" id="toc-installation">Installation</a>
- <a href="#usage" id="toc-usage">Usage</a>
- <a href="#more-information" id="toc-more-information">More
  Information</a>
  - <a href="#population-survey" id="toc-population-survey">Population
    survey</a>
    - <a href="#estimated-population-estimated_pop"
      id="toc-estimated-population-estimated_pop">Estimated Population
      (#estimated_pop)</a>
    - <a href="#estimated-variance" id="toc-estimated-variance">Estimated
      Variance</a>
  - <a href="#mobility-and-transport-survey"
    id="toc-mobility-and-transport-survey">Mobility and Transport Survey</a>

<!-- README.md is generated from README.Rmd. Please edit that file -->

# BFSestimates

The goal of BFSestimates is to estimate the population, variance and
confidence intervals from surveys conducted by *Bundesamt für Statistik*
(BFS) / *Office fédéral de la statistique* (OFS):

- population survey (*Volkszählung* (VZ), *recensement de la
  population*),
- mobility and transport survey (*Mikrozensus Mobilität und Verkehr*
  (MZMV), *Microrecensement mobilité et transports* (MRMT)).

# Installation

You can install the development version of `BFSestimates` like so:

``` r
devtools::install_github("BFSestimates", "souadg")
```

# Usage

Population survey estimates:

``` r
library(BFSestimates)
library(dplyr)
estimate_pop_cens(data = nhanes, 
                       weight_colname = "weights", 
                       strata_variable = "strata",
                       condition_col = "gender")
#> # A tibble: 2 × 7
#>   gender      total    vhat   occ       sd       ci ci_per
#>   <fct>       <dbl>   <dbl> <int>    <dbl>    <dbl>  <dbl>
#> 1 Male   146242153. 7.52e12  4592 2741918. 5374060.   3.67
#> 2 Female 151475830. 7.30e12  4715 2702304. 5296418.   3.50
```

Mobility survey estimates:

# More Information

From the survey data, `BFestimates` estimates:

- occurrences in the real population: sum of weights of sub-population
  of interest (see Equation);
- variance
  ![\hat V](https://latex.codecogs.com/png.latex?%5Chat%20V "\hat V") of
  the estimate;
- standard deviation
  (![sd = \sqrt{\hat{V}}](https://latex.codecogs.com/png.latex?sd%20%3D%20%5Csqrt%7B%5Chat%7BV%7D%7D "sd = \sqrt{\hat{V}}"))
  of the estimate;
- ![95\\%](https://latex.codecogs.com/png.latex?95%5C%25 "95\%")
  confidence interval of the estimate:
  ![\pm 97.5^{\text{th}}](https://latex.codecogs.com/png.latex?%5Cpm%2097.5%5E%7B%5Ctext%7Bth%7D%7D "\pm 97.5^{\text{th}}")
  centile of normal distribution with mean
  ![0](https://latex.codecogs.com/png.latex?0 "0") and standard
  deviation
  ![\sqrt{\hat{V}}](https://latex.codecogs.com/png.latex?%5Csqrt%7B%5Chat%7BV%7D%7D "\sqrt{\hat{V}}");

## Population survey

The BFS/OFS provides [formulas to estimate populations and
variances](https://portal.collab.admin.ch/sites/317-SE-CUG) in French
(`do-f-40-se_METH.pdf`) and German(`do-d-40-se_METH.pdf`).

### Estimated Population (#estimated_pop)

The estimated populations from the population survey is given by:

![\hat{N}\_c = \sum\_{i \in r} w_i I_c](https://latex.codecogs.com/png.latex?%5Chat%7BN%7D_c%20%3D%20%5Csum_%7Bi%20%5Cin%20r%7D%20w_i%20I_c "\hat{N}_c = \sum_{i \in r} w_i I_c")

where:

- ![w_i](https://latex.codecogs.com/png.latex?w_i "w_i") the weight for
  participant ![i](https://latex.codecogs.com/png.latex?i "i");
- ![I_c = 1](https://latex.codecogs.com/png.latex?I_c%20%3D%201 "I_c = 1")
  if condition(s) ![c](https://latex.codecogs.com/png.latex?c "c") is
  true, 0 otherwise;
- ![r](https://latex.codecogs.com/png.latex?r "r") is the set of
  participants

### Estimated Variance

The estimated variance is given by:

![\hat{V}(\hat{N}\_c) = \sum_h \frac{m_h}{m_h - 1}\left(1 - \frac{m_h}{N_h}\right) \sum\_{i \in r_h}\left(w_i I_c - \frac{\hat{N}\_{hc}}{m_h}\right)^2](https://latex.codecogs.com/png.latex?%5Chat%7BV%7D%28%5Chat%7BN%7D_c%29%20%3D%20%5Csum_h%20%5Cfrac%7Bm_h%7D%7Bm_h%20-%201%7D%5Cleft%281%20-%20%5Cfrac%7Bm_h%7D%7BN_h%7D%5Cright%29%20%5Csum_%7Bi%20%5Cin%20r_h%7D%5Cleft%28w_i%20I_c%20-%20%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2 "\hat{V}(\hat{N}_c) = \sum_h \frac{m_h}{m_h - 1}\left(1 - \frac{m_h}{N_h}\right) \sum_{i \in r_h}\left(w_i I_c - \frac{\hat{N}_{hc}}{m_h}\right)^2")

where:

- ![\hat{N}\_c](https://latex.codecogs.com/png.latex?%5Chat%7BN%7D_c "\hat{N}_c")
  is the estimated occurrence of condition
  ![c](https://latex.codecogs.com/png.latex?c "c");
- ![h](https://latex.codecogs.com/png.latex?h "h") designates a stratum
  (e.g. `zone`)
- ![\hat{N}\_{hc}](https://latex.codecogs.com/png.latex?%5Chat%7BN%7D_%7Bhc%7D "\hat{N}_{hc}")
  is the estimated occurrence of coditions
  ![c](https://latex.codecogs.com/png.latex?c "c") in stratum
  ![h](https://latex.codecogs.com/png.latex?h "h");
- ![N_h](https://latex.codecogs.com/png.latex?N_h "N_h") is the total
  estimated population in stratum
  ![h](https://latex.codecogs.com/png.latex?h "h") (sum of weights in
  stratum h);
- ![r_h](https://latex.codecogs.com/png.latex?r_h "r_h") is the set of
  participants in stratum
  ![h](https://latex.codecogs.com/png.latex?h "h");
- ![m_h](https://latex.codecogs.com/png.latex?m_h "m_h") is the number
  of participants in stratum
  ![h](https://latex.codecogs.com/png.latex?h "h").

Note that the second summation is over the whole stratum, so for
condition ![c](https://latex.codecogs.com/png.latex?c "c") this becomes:

![\begin{aligned}
\sum\_{i \in r_h}\left(w_i I_c - \frac{\hat{N}\_{hc}}{m_h}\right)^2 &=
\sum\_{i \notin r\_{hc}} \left(\frac{\hat{N}\_{hc}}{m_h}\right)^2 + \sum\_{i \in r\_{hc}} \left(w_i - \frac{\hat{N}\_{hc}}{m_h}\right)^2 \\\\
&= \left(m_h - m\_{hc}\right) \left(\frac{\hat{N}\_{hc}}{m_h}\right)^2  + \sum\_{i \in r\_{hc}} \left(w_i - \frac{\hat{N}\_{hc}}{m_h}\right)^2
\end{aligned}](https://latex.codecogs.com/png.latex?%5Cbegin%7Baligned%7D%0A%5Csum_%7Bi%20%5Cin%20r_h%7D%5Cleft%28w_i%20I_c%20-%20%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%20%26%3D%0A%5Csum_%7Bi%20%5Cnotin%20r_%7Bhc%7D%7D%20%5Cleft%28%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%20%2B%20%5Csum_%7Bi%20%5Cin%20r_%7Bhc%7D%7D%20%5Cleft%28w_i%20-%20%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%20%5C%5C%0A%26%3D%20%5Cleft%28m_h%20-%20m_%7Bhc%7D%5Cright%29%20%5Cleft%28%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%20%20%2B%20%5Csum_%7Bi%20%5Cin%20r_%7Bhc%7D%7D%20%5Cleft%28w_i%20-%20%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%0A%5Cend%7Baligned%7D "\begin{aligned}
\sum_{i \in r_h}\left(w_i I_c - \frac{\hat{N}_{hc}}{m_h}\right)^2 &=
\sum_{i \notin r_{hc}} \left(\frac{\hat{N}_{hc}}{m_h}\right)^2 + \sum_{i \in r_{hc}} \left(w_i - \frac{\hat{N}_{hc}}{m_h}\right)^2 \\
&= \left(m_h - m_{hc}\right) \left(\frac{\hat{N}_{hc}}{m_h}\right)^2  + \sum_{i \in r_{hc}} \left(w_i - \frac{\hat{N}_{hc}}{m_h}\right)^2
\end{aligned}")

where
![r\_{hc}](https://latex.codecogs.com/png.latex?r_%7Bhc%7D "r_{hc}") is
the set of respondents in stratum
![h](https://latex.codecogs.com/png.latex?h "h") who fulfill condition
![c](https://latex.codecogs.com/png.latex?c "c") and
![m\_{hc}](https://latex.codecogs.com/png.latex?m_%7Bhc%7D "m_{hc}") the
number of respondents in
![r\_{hc}](https://latex.codecogs.com/png.latex?r_%7Bhc%7D "r_{hc}").

Finally the original variance estimate equation becomes:

![\hat{V}(\hat{N}\_c) = \sum_h \frac{m_h}{m_h - 1}\left(1 - \frac{m_h}{N_h}\right) \left\[(m_h - m\_{hc}) \left(\frac{\hat{N}\_{hc}}{m_h}\right)^2  + \sum\_{i \in r\_{hc}} \left(w_i - \frac{\hat{N}\_{hc}}{m_h}\right)^2\right\]](https://latex.codecogs.com/png.latex?%5Chat%7BV%7D%28%5Chat%7BN%7D_c%29%20%3D%20%5Csum_h%20%5Cfrac%7Bm_h%7D%7Bm_h%20-%201%7D%5Cleft%281%20-%20%5Cfrac%7Bm_h%7D%7BN_h%7D%5Cright%29%20%5Cleft%5B%28m_h%20-%20m_%7Bhc%7D%29%20%5Cleft%28%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%20%20%2B%20%5Csum_%7Bi%20%5Cin%20r_%7Bhc%7D%7D%20%5Cleft%28w_i%20-%20%5Cfrac%7B%5Chat%7BN%7D_%7Bhc%7D%7D%7Bm_h%7D%5Cright%29%5E2%5Cright%5D "\hat{V}(\hat{N}_c) = \sum_h \frac{m_h}{m_h - 1}\left(1 - \frac{m_h}{N_h}\right) \left[(m_h - m_{hc}) \left(\frac{\hat{N}_{hc}}{m_h}\right)^2  + \sum_{i \in r_{hc}} \left(w_i - \frac{\hat{N}_{hc}}{m_h}\right)^2\right]")

`summarise_pop()` calculates
![m_h, N_h, m\_{hc}, \text{and } \hat{N}\_{hc}](https://latex.codecogs.com/png.latex?m_h%2C%20N_h%2C%20m_%7Bhc%7D%2C%20%5Ctext%7Band%20%7D%20%5Chat%7BN%7D_%7Bhc%7D "m_h, N_h, m_{hc}, \text{and } \hat{N}_{hc}").

`estimate_pop_cens()` implements the variance equation for
![\hat{V}(\hat{N}\_c)](https://latex.codecogs.com/png.latex?%5Chat%7BV%7D%28%5Chat%7BN%7D_c%29 "\hat{V}(\hat{N}_c)")
and calculates true occurrence in the survey sample and confidence
intervals.

## Mobility and Transport Survey
