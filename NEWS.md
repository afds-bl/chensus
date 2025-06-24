# chensus 2.0.0.

## New features

- Renamed `se_mean_cat()` to `se_prop()`.
- Renamed `se_mean_num()` to `se_mean()`.
- Added `se_total_prop()` to estimate totals and proportions of categorical variables.
- Added `se_total_comb()` and `se_mean_comb()` to estimate totals and means, respectively, for all possible grouping variable combinations.

# chensus 1.0.0

## New features

- Initial release of `chensus` package.

## Changes

- Updated functions to support tidy evaluation (unquoted arguments).
- Separated `se_mean()` into two functions: `se_mean_num()` and `se_mean_cat()`.
- Replaced the `condition` argument with the ellipsis `...`.
