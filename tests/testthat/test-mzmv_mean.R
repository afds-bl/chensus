test_that("mzmv_mean computes weighted means and CI correctly for quoted and unquoted variables", {
  # Sample data
  df <- tibble(
    annual_household_income = c(10, 20, 30, 40),
    household_size = c(2, 1, 4, 3),
    gender = c("M", "F", "M", "F"),
    region = c("North", "South", "North", "South"),
    weights = 1:4
  )
  
  # Expected weighted means
  wh_income <- weighted.mean(c(10, 20, 30, 40), c(1, 2, 3, 4))
  wh_size   <- weighted.mean(c(2, 1, 4, 3), c(1, 2, 3, 4))
  
  # Test unquoted variables
  result_unquoted <- mzmv_mean(df, annual_household_income, household_size, weight = weights)
  expect_true(all(c("variable", "occ", "wmean", "ci") %in% colnames(result_unquoted)))
  expect_s3_class(result_unquoted, "tbl_df")
  expect_equal(result_unquoted$occ[result_unquoted$variable == "annual_household_income"], 4)
  expect_equal(result_unquoted$occ[result_unquoted$variable == "household_size"], 4)
  expect_equal(result_unquoted$wmean[result_unquoted$variable == "annual_household_income"], wh_income)
  expect_equal(result_unquoted$wmean[result_unquoted$variable == "household_size"], wh_size)
  expect_true(all(result_unquoted$ci >= 0 | is.na(result_unquoted$ci)))
  
  # Test using symbols programmatically
  vars <- c("annual_household_income", "household_size")
  result_syms <- mzmv_mean(df, !!!rlang::syms(vars), weight = "weights")
  expect_equal(result_syms, result_unquoted, ignore_attr = TRUE)
})
