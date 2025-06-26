# chensus 2.1.0

- Added `se_prop_ogd()` and `se_total_prop_ogd()`.

# chensus 2.0.0.

## New features

- Renamed `se_mean_cat()` to `se_prop()`.
- Renamed `se_mean_num()` to `se_mean()`.
- Added `se_total_prop()` to estimate totals and proportions of categorical variables.
- Added `se_total_ogd()` and `se_mean_ogd()` to estimate totals and means, respectively, for all possible grouping variable combinations.

# chensus 1.0.0

## New features

- Initial release of `chensus` package.

## Changes

- Combined total and proportion estimates in a single table using `se_total_prop()`.
- Changed `se_mean_cat()` into `se_prop()`.
- Updated functions to support tidy evaluation (unquoted arguments).
- Separated `se_mean()` into two functions: `se_mean_num()` and `se_mean_cat()`.
- Replaced the `condition` argument with the ellipsis `...`.
