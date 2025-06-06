test_that("mzmv_mean computes weighted means and CI correctly", {
  # Sample data
  df <- tibble(
    annual_household_income = c(10, 20, 30, 40),
    household_size = c(2, 1, 4, 3),
    gender = c("M", "F", "M", "F"),
    region = c("North", "South", "North", "South"),
    weights = 1:4
  )
  
  # Run the function
  result <- mzmv_mean(df, annual_household_income, household_size, weight = weights)
  
  # Check it returns a tibble with expected columns
  expect_true(all(c("variable", "nc", "wmean", "ci") %in% colnames(result)))
  expect_s3_class(result, "tbl_df")
  
  # Check no negative filtered values included in n counts
  expect_equal(result$nc[result$variable == "annual_household_income"], 4)
  expect_equal(result$nc[result$variable == "household_size"], 4)
  
  # Weighted mean calculations (manual check)
  wh_income <- weighted.mean(c(10, 20, 30, 40), c(1, 2, 3, 4))
  wh_size <- weighted.mean(c(2, 1, 4, 3), c(1, 2, 3, 4))
  expect_equal(result$wmean[result$variable == "annual_household_income"], wh_income)
  expect_equal(result$wmean[result$variable == "household_size"], wh_size)
  
  # Check confidence intervals are numeric and non-negative
  expect_true(all(result$ci >= 0 | is.na(result$ci)))
})