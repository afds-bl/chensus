
- <a href="#bfsestimates" id="toc-bfsestimates">BFSestimates</a>
- <a href="#installation" id="toc-installation">Installation</a>
- <a href="#usage" id="toc-usage">Usage</a>
- <a href="#more-information" id="toc-more-information">More
  Information</a>
  - <a href="#population-survey" id="toc-population-survey">Population
    survey</a>
    - <a href="#estimated-population" id="toc-estimated-population">Estimated
      Population</a>
    - <a href="#estimated-variance" id="toc-estimated-variance">Estimated
      Variance</a>
  - <a href="#mobility-and-transport-survey"
    id="toc-mobility-and-transport-survey">Mobility and Transport Survey</a>
    - <a href="#estimated-mean" id="toc-estimated-mean">Estimated Mean</a>
    - <a href="#estimated-proportion" id="toc-estimated-proportion">Estimated
      Proportion</a>

<!-- README.md is generated from README.Rmd. Please edit that file -->

# BFSestimates

The goal of BFSestimates is to estimate population frequencies, means,
proportions and confidence intervals from surveys conducted by
*Bundesamt für Statistik* (BFS) / *Office fédéral de la statistique*
(OFS):

- population survey (*Volkszählung* (VZ), *recensement de la
  population*),
- mobility and transport survey (*Mikrozensus Mobilität und Verkehr*
  (MZMV), *Microrecensement mobilité et transports* (MRMT)).

# Installation

You can install the development version of `BFSestimates` like so:

``` r
install.packages('BFSestimates_0.1.0.tar.gz', repos=NULL, type='source')
```

# Usage

Population survey estimates:

``` r
library(BFSestimates)
library(dplyr)
vz_estimate(
  data = nhanes,
  weight = "weights",
  strata = "strata",
  condition = "gender"
)
#> # A tibble: 2 × 7
#>   gender      total    vhat   occ       sd       ci ci_per
#>   <fct>       <dbl>   <dbl> <int>    <dbl>    <dbl>  <dbl>
#> 1 Male   146242153. 7.52e12  4592 2741918. 5374060.   3.67
#> 2 Female 151475830. 7.30e12  4715 2702304. 5296418.   3.50
```

Mobility survey estimates:

``` r
library(BFSestimates)
library(dplyr)
mzmv_estimate_mean(
  data = nhanes,
  object = c("annual_household_income", "annual_family_income"),
  weight = "weights"
)
#>                        id   nc    wmean        ci
#> 1 annual_household_income 9307 11.77473 0.2852000
#> 2    annual_family_income 9307 11.42304 0.2875722
```

# More Information

## Population survey

From the survey data, `vz_estimate()` estimates:

- occurrences in the real population: sum of weights of sub-population
  of interest;
- variance
  ![\hat V](https://latex.codecogs.com/png.latex?%5Chat%20V "\hat V") of
  the estimate;
- standard deviation
  (![sd = \sqrt{\hat{V}}](https://latex.codecogs.com/png.latex?sd%20%3D%20%5Csqrt%7B%5Chat%7BV%7D%7D "sd = \sqrt{\hat{V}}"))
  of the estimate;
- confidence interval of the estimate with significance level
  ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha"):
  ![\left\[(1 - \alpha/2)\times 100\right\]^{\text{th}}](https://latex.codecogs.com/png.latex?%5Cleft%5B%281%20-%20%5Calpha%2F2%29%5Ctimes%20100%5Cright%5D%5E%7B%5Ctext%7Bth%7D%7D "\left[(1 - \alpha/2)\times 100\right]^{\text{th}}")
  percentile of normal distribution with mean
  ![0](https://latex.codecogs.com/png.latex?0 "0") and standard
  deviation
  ![\sqrt{\hat{V}}](https://latex.codecogs.com/png.latex?%5Csqrt%7B%5Chat%7BV%7D%7D "\sqrt{\hat{V}}").

The BFS/OFS provides [formulas to estimate populations and
variances](https://portal.collab.admin.ch/sites/317-SE-CUG) in French
(`do-f-40-se_METH.pdf`) and German(`do-d-40-se_METH.pdf`).

### Estimated Population

The estimated populations from the population survey is given by:

![\hat{N}\_c = \sum\_{i \in r} w_i I_c](https://latex.codecogs.com/png.latex?%5Chat%7BN%7D_c%20%3D%20%5Csum_%7Bi%20%5Cin%20r%7D%20w_i%20I_c "\hat{N}_c = \sum_{i \in r} w_i I_c")

where:

- ![w_i](https://latex.codecogs.com/png.latex?w_i "w_i") is the weight
  for participant ![i](https://latex.codecogs.com/png.latex?i "i");
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

The confidence interval is given by:

![\text{CI} = \sqrt{\hat{V}(\hat{N}\_c)} \times \text{qnorm}(1 - \frac{\alpha}2)](https://latex.codecogs.com/png.latex?%5Ctext%7BCI%7D%20%3D%20%5Csqrt%7B%5Chat%7BV%7D%28%5Chat%7BN%7D_c%29%7D%20%5Ctimes%20%5Ctext%7Bqnorm%7D%281%20-%20%5Cfrac%7B%5Calpha%7D2%29 "\text{CI} = \sqrt{\hat{V}(\hat{N}_c)} \times \text{qnorm}(1 - \frac{\alpha}2)")

where ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha")
is the significance level, for example 0.05 for confidence interval 95%.

`vz_summarise()` calculates
![m_h, N_h, m\_{hc}, \text{and } \hat{N}\_{hc}](https://latex.codecogs.com/png.latex?m_h%2C%20N_h%2C%20m_%7Bhc%7D%2C%20%5Ctext%7Band%20%7D%20%5Chat%7BN%7D_%7Bhc%7D "m_h, N_h, m_{hc}, \text{and } \hat{N}_{hc}").

`vz_estimate()` calculates
![\hat{V}(\hat{N}\_c)](https://latex.codecogs.com/png.latex?%5Chat%7BV%7D%28%5Chat%7BN%7D_c%29 "\hat{V}(\hat{N}_c)"),
the true occurrence in the survey sample and confidence intervals.

## Mobility and Transport Survey

From the survey data, `mzmv_estimate_mean()` estimates:

- average occurrence in the real population: weighted mean of
  sub-population of interest;
- confidence interval of the estimate with significance level
  ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha"),

while `mzmv_estimate_prop()` estimates:

- proportions in the real population
- confidence interval of the proportion estimate with significance level
  ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha").

### Estimated Mean

The estimated mean is:

![\hat{Y} = \frac{1}{\sum\limits\_{i\in r} w_i}\sum\_{i \in r} w_i y_i](https://latex.codecogs.com/png.latex?%5Chat%7BY%7D%20%3D%20%5Cfrac%7B1%7D%7B%5Csum%5Climits_%7Bi%5Cin%20r%7D%20w_i%7D%5Csum_%7Bi%20%5Cin%20r%7D%20w_i%20y_i "\hat{Y} = \frac{1}{\sum\limits_{i\in r} w_i}\sum_{i \in r} w_i y_i")

where:

- ![w_i](https://latex.codecogs.com/png.latex?w_i "w_i") is the weight
  for participant ![i](https://latex.codecogs.com/png.latex?i "i");
- ![y_i](https://latex.codecogs.com/png.latex?y_i "y_i") is the response
  of participant ![i](https://latex.codecogs.com/png.latex?i "i");
- ![r](https://latex.codecogs.com/png.latex?r "r") is the set of
  respondents with condition
  ![c](https://latex.codecogs.com/png.latex?c "c").

The [confidence interval of the estimated
mean](https://www.bfs.admin.ch/bfs/fr/home/statistiques/mobilite-transports/enquetes/mzmv.assetdetail.4262242.html)
is:

![\begin{aligned}\text{CI} &= 
1.14\times Z\_{\alpha}\frac{\hat{\sigma}\_{y}}{\sqrt{n}}\\\\
&= 1.14 \times \frac{\hat{\sigma}\_{y}}{\sqrt{n}} \times \text{qnorm}(1 - \frac{\alpha}2)
\end{aligned}](https://latex.codecogs.com/png.latex?%5Cbegin%7Baligned%7D%5Ctext%7BCI%7D%20%26%3D%20%0A1.14%5Ctimes%20Z_%7B%5Calpha%7D%5Cfrac%7B%5Chat%7B%5Csigma%7D_%7By%7D%7D%7B%5Csqrt%7Bn%7D%7D%5C%5C%0A%26%3D%201.14%20%5Ctimes%20%5Cfrac%7B%5Chat%7B%5Csigma%7D_%7By%7D%7D%7B%5Csqrt%7Bn%7D%7D%20%5Ctimes%20%5Ctext%7Bqnorm%7D%281%20-%20%5Cfrac%7B%5Calpha%7D2%29%0A%5Cend%7Baligned%7D "\begin{aligned}\text{CI} &= 
1.14\times Z_{\alpha}\frac{\hat{\sigma}_{y}}{\sqrt{n}}\\
&= 1.14 \times \frac{\hat{\sigma}_{y}}{\sqrt{n}} \times \text{qnorm}(1 - \frac{\alpha}2)
\end{aligned}")

where:

- 1.14 is a correction factor;
- ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha") is
  the significance level, for example 0.05 for confidence interval 95%;
- ![Z\_{\alpha}](https://latex.codecogs.com/png.latex?Z_%7B%5Calpha%7D "Z_{\alpha}")
  is the [Z-value](https://www.z-table.com/) for the desired confidence
  level
  (![Z\_{0.05} = 1.96](https://latex.codecogs.com/png.latex?Z_%7B0.05%7D%20%3D%201.96 "Z_{0.05} = 1.96")
  for double-sided 95% confidence interval);
- ![n](https://latex.codecogs.com/png.latex?n "n") is the size of set
  ![r](https://latex.codecogs.com/png.latex?r "r"), i.e. number of
  respondents with condition
  ![c](https://latex.codecogs.com/png.latex?c "c");
- ![\hat{\sigma}\_{y}^2](https://latex.codecogs.com/png.latex?%5Chat%7B%5Csigma%7D_%7By%7D%5E2 "\hat{\sigma}_{y}^2")
  is the variance of variable
  ![Y](https://latex.codecogs.com/png.latex?Y "Y") estimated with sample
  ![r](https://latex.codecogs.com/png.latex?r "r").

The (sample) variance of variable
![Y](https://latex.codecogs.com/png.latex?Y "Y") is estimated by:

![\hat{\sigma}\_{y}^2 = \frac{\sum\limits\_{i\in r} w_i \left(y_i - \bar{y}\right)^2}{\left(\sum\limits\_{i \in r} w_i \right)- 1}](https://latex.codecogs.com/png.latex?%5Chat%7B%5Csigma%7D_%7By%7D%5E2%20%3D%20%5Cfrac%7B%5Csum%5Climits_%7Bi%5Cin%20r%7D%20w_i%20%5Cleft%28y_i%20-%20%5Cbar%7By%7D%5Cright%29%5E2%7D%7B%5Cleft%28%5Csum%5Climits_%7Bi%20%5Cin%20r%7D%20w_i%20%5Cright%29-%201%7D "\hat{\sigma}_{y}^2 = \frac{\sum\limits_{i\in r} w_i \left(y_i - \bar{y}\right)^2}{\left(\sum\limits_{i \in r} w_i \right)- 1}")

where
![\bar{y}](https://latex.codecogs.com/png.latex?%5Cbar%7By%7D "\bar{y}")
is the estimated mean
![\hat{Y}](https://latex.codecogs.com/png.latex?%5Chat%7BY%7D "\hat{Y}").

### Estimated Proportion

If
![y_i \in \\{0, 1\\}](https://latex.codecogs.com/png.latex?y_i%20%5Cin%20%5C%7B0%2C%201%5C%7D "y_i \in \{0, 1\}"),
for example possession of a car, then the mean estimate becomes the
proportion estimate:

![p = \frac{1}{\sum\limits\_{i \in r} w_i} \sum\_{i \in r} w_i I_c](https://latex.codecogs.com/png.latex?p%20%3D%20%5Cfrac%7B1%7D%7B%5Csum%5Climits_%7Bi%20%5Cin%20r%7D%20w_i%7D%20%5Csum_%7Bi%20%5Cin%20r%7D%20w_i%20I_c "p = \frac{1}{\sum\limits_{i \in r} w_i} \sum_{i \in r} w_i I_c")

where:

- ![w_i](https://latex.codecogs.com/png.latex?w_i "w_i") is the weight
  for participant ![i](https://latex.codecogs.com/png.latex?i "i");
- ![I_c = 1](https://latex.codecogs.com/png.latex?I_c%20%3D%201 "I_c = 1")
  if condition ![c](https://latex.codecogs.com/png.latex?c "c") is true
  (![y_i = 1](https://latex.codecogs.com/png.latex?y_i%20%3D%201 "y_i = 1")),
  0 otherwise
  (![y_i = 0](https://latex.codecogs.com/png.latex?y_i%20%3D%200 "y_i = 0"));
- ![r](https://latex.codecogs.com/png.latex?r "r") is the set of
  participants.

The sample variance in the previous section then becomes:

![\hat{\sigma}\_{p}^2 = \frac{\sum\limits\_{i\in r} w_i \left(I_c - p\right)^2}{\left(\sum\limits\_{i \in r} w_i \right)- 1}](https://latex.codecogs.com/png.latex?%5Chat%7B%5Csigma%7D_%7Bp%7D%5E2%20%3D%20%5Cfrac%7B%5Csum%5Climits_%7Bi%5Cin%20r%7D%20w_i%20%5Cleft%28I_c%20-%20p%5Cright%29%5E2%7D%7B%5Cleft%28%5Csum%5Climits_%7Bi%20%5Cin%20r%7D%20w_i%20%5Cright%29-%201%7D "\hat{\sigma}_{p}^2 = \frac{\sum\limits_{i\in r} w_i \left(I_c - p\right)^2}{\left(\sum\limits_{i \in r} w_i \right)- 1}")

Noting that
![I_c^2 = I_c](https://latex.codecogs.com/png.latex?I_c%5E2%20%3D%20I_c "I_c^2 = I_c")
and
![\sum\limits_i w_i I_c = p \sum\limits_i w_i](https://latex.codecogs.com/png.latex?%5Csum%5Climits_i%20w_i%20I_c%20%3D%20p%20%5Csum%5Climits_i%20w_i "\sum\limits_i w_i I_c = p \sum\limits_i w_i"),
the nominator then becomes:

![\begin{aligned} \sum\limits\_{i\in r} w_i \left(I_c - p\right)^2 &=
\sum_i w_i \left(I_c^2 +p^2 -2pI_c\right) \\\\
&= \sum_i w_i I_c + p^2 \sum_i w_i -2p\sum_i w_i I_c\\\\
&= p \sum_i w_i + p^2 \sum_i w_i - 2p^2 \sum_i w_i\\\\
&= p \sum_i w_i - p^2 \sum_i w_i\\\\
&= p(1-p) \sum_i w_i
\end{aligned}](https://latex.codecogs.com/png.latex?%5Cbegin%7Baligned%7D%20%5Csum%5Climits_%7Bi%5Cin%20r%7D%20w_i%20%5Cleft%28I_c%20-%20p%5Cright%29%5E2%20%26%3D%0A%5Csum_i%20w_i%20%5Cleft%28I_c%5E2%20%2Bp%5E2%20-2pI_c%5Cright%29%20%5C%5C%0A%26%3D%20%5Csum_i%20w_i%20I_c%20%2B%20p%5E2%20%5Csum_i%20w_i%20-2p%5Csum_i%20w_i%20I_c%5C%5C%0A%26%3D%20p%20%5Csum_i%20w_i%20%2B%20p%5E2%20%5Csum_i%20w_i%20-%202p%5E2%20%5Csum_i%20w_i%5C%5C%0A%26%3D%20p%20%5Csum_i%20w_i%20-%20p%5E2%20%5Csum_i%20w_i%5C%5C%0A%26%3D%20p%281-p%29%20%5Csum_i%20w_i%0A%5Cend%7Baligned%7D "\begin{aligned} \sum\limits_{i\in r} w_i \left(I_c - p\right)^2 &=
\sum_i w_i \left(I_c^2 +p^2 -2pI_c\right) \\
&= \sum_i w_i I_c + p^2 \sum_i w_i -2p\sum_i w_i I_c\\
&= p \sum_i w_i + p^2 \sum_i w_i - 2p^2 \sum_i w_i\\
&= p \sum_i w_i - p^2 \sum_i w_i\\
&= p(1-p) \sum_i w_i
\end{aligned}")

Therefore, the estimated sample variance becomes:

![\hat{\sigma}\_{p}^2 = \frac{p(1-p) \sum\limits\_{i} w_i}{\left(\sum\limits\_{i} w_i \right)- 1}](https://latex.codecogs.com/png.latex?%5Chat%7B%5Csigma%7D_%7Bp%7D%5E2%20%3D%20%5Cfrac%7Bp%281-p%29%20%5Csum%5Climits_%7Bi%7D%20w_i%7D%7B%5Cleft%28%5Csum%5Climits_%7Bi%7D%20w_i%20%5Cright%29-%201%7D "\hat{\sigma}_{p}^2 = \frac{p(1-p) \sum\limits_{i} w_i}{\left(\sum\limits_{i} w_i \right)- 1}")

which when
![\sum\limits_i w_i \>\> 1](https://latex.codecogs.com/png.latex?%5Csum%5Climits_i%20w_i%20%3E%3E%201 "\sum\limits_i w_i >> 1")
becomes:

![\hat{\sigma}\_{p}^2 \approx p(1-p)](https://latex.codecogs.com/png.latex?%5Chat%7B%5Csigma%7D_%7Bp%7D%5E2%20%5Capprox%20p%281-p%29 "\hat{\sigma}_{p}^2 \approx p(1-p)")

The confidence interval for proportions can be approximated by:

![\text{CI} \approx 1.14 \times \sqrt{\frac{p(1-p)}{n}} \times \text{qnorm}(1 - \frac{\alpha} 2)](https://latex.codecogs.com/png.latex?%5Ctext%7BCI%7D%20%5Capprox%201.14%20%5Ctimes%20%5Csqrt%7B%5Cfrac%7Bp%281-p%29%7D%7Bn%7D%7D%20%5Ctimes%20%5Ctext%7Bqnorm%7D%281%20-%20%5Cfrac%7B%5Calpha%7D%202%29 "\text{CI} \approx 1.14 \times \sqrt{\frac{p(1-p)}{n}} \times \text{qnorm}(1 - \frac{\alpha} 2)")

where:

- ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha") is
  the siginificance level;
- ![\text{qnorm}](https://latex.codecogs.com/png.latex?%5Ctext%7Bqnorm%7D "\text{qnorm}")
  outputs the Z-score for the required significance level
  ![\alpha](https://latex.codecogs.com/png.latex?%5Calpha "\alpha");
- ![n](https://latex.codecogs.com/png.latex?n "n") is the size of set
  ![r](https://latex.codecogs.com/png.latex?r "r"), i.e. number of
  respondents.
