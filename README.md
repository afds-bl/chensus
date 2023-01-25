
<!-- README.md is generated from README.Rmd. Please edit that file -->

## BFSestimates

<!-- badges: start -->
<!-- badges: end -->

The goal of BFSestimates is to estimate the population, variance and
confidence intervals from censuses conducted by *Bundesamt für
Statistik* (BFS) / *Office National de la Statistique* (OFS),
specifically:

- population census (*Volkzählung* (VZ), *recensement de la population*)
- mobility and transport microcensus (*Mikrozensus Mobilität und Verkeh*
  (MZMV), *Microrecensement mobilité et transports* (MRMT))

From the survey data, We would like to estimate:

- occurrences in the real population: sum of weights of subpopulation of
  interest;
- variance $\hat V$ of the above estimate;
- standard deviation ($sd = \sqrt{\hat{V}}$) of the estimate;
- $95\%$ confidence interval of the estimate: $\pm 97.5^{\text{th}}$
  centile of normal distribution with mean $0$ and standard deviation
  $\sqrt{\hat{V}}$;

### Population Census

The BFS provides [formulas to estimate populations and
variances](https://portal.collab.admin.ch/sites/317-SE-CUG) in French
(`do-f-40-se_METH.pdf`) and German(`do-d-40-se_METH.pdf`).

#### Estimated Population

The estimated populations from the population census is given by:

$$\hat{N}_c = \sum_{i \in r} w_i I_c$$ where:

- $w_i$ the weight for participant $i$;
- $I_c = 1$ if condition(s) $c$ is true, 0 otherwise;
- $r$ is the set of participants

#### Estimated Variance

The estimated variance is given by:
$$\hat{V}(\hat{N}_c) = \sum_h \frac{m_h}{m_h - 1}\left(1 - \frac{m_h}{N_h}\right) \sum_{i \in r_h}\left(w_i I_c - \frac{\hat{N}_{hc}}{m_h}\right)^2$$

where:

- $\hat{N}_c$ is the estimated occurrence of condition $c$;
- $h$ designates a stratum (*zone* in our case)
- $\hat{N}_{hc}$ is the estimated occurrence of coditions $c$ in stratum
  $h$;
- $N_h$ is the total estimated population in stratum $h$ (sum of weights
  in stratum h);
- $r_h$ is the set of participants in stratum $h$;
- $m_h$ is the number of participants in stratum $h$.

Note that the second summation is over the whole stratum, so for
condition $c$ this becomes: $$
\begin{aligned}
\sum_{i \in r_h}\left(w_i I_c - \frac{\hat{N}_{hc}}{m_h}\right)^2 &=
\sum_{i \notin r_{c,h}} \left(\frac{\hat{N}_{hc}}{m_h}\right)^2 + \sum_{i \in r_{c,h}} \left(w_i - \frac{\hat{N}_{hc}}{m_h}\right)^2 \\
&= \left(m_h - m_{hc}\right) \left(\frac{\hat{N}_{hc}}{m_h}\right)^2  + \sum_{i \in r_{c,h}} \left(w_i - \frac{\hat{N}_{hc}}{m_h}\right)^2
\end{aligned}
$$ where $r_{c,h}$ is the set of respondents in zone $h$ who fulfill
condition $c$ and $mhc$ the number of respondents in $r_{hc}$.

Finally the original variance estimate equation becomes:

$$\hat{V}(\hat{N}_c) = \sum_h \frac{m_h}{m_h - 1}\left(1 - \frac{m_h}{N_h}\right) \left[(m_h - m_{hc}) \left(\frac{\hat{N}_{hc}}{m_h}\right)^2  + \sum_{i \in r_{c,h}} \left(w_i - \frac{\hat{N}_{hc}}{m_h}\right)^2\right]$$

`summarise_pop()` calculates
$m_h, N_h, m_{hc}, \text{and } \hat{N}_{hc}$.

`estimate_pop_cens()` implements the variance equation for
$\hat{V}(\hat{N}_c)$.

### Mobility and Transport Microcensus

## Installation

You can install the development version of BFSestimates like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(BFSestimates)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
