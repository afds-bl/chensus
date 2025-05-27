test_that("mzmv_mean computes weighted means and confidence intervals correctly", {
  # Sample test data
  df <- tibble(
    annual_household_income = c(10, 20, 30, -1, 40),
    annual_family_income = c(15, 25, 35, 45, -5),
    weights = c(1, 2, 3, 4, 5)
  )
  
  result <- mzmv_mean(df, variable = c("annual_household_income", "annual_family_income"), weight = "weights", cf = 1, alpha = 0.1)
  
  # Check it returns a tibble with expected columns
  expect_true(all(c("variable", "nc", "wmean", "ci") %in% colnames(result)))
  expect_s3_class(result, "tbl_df")
  
  # Check no negative filtered values included in n counts
  expect_equal(result$nc[result$variable == "annual_household_income"], 4)
  expect_equal(result$nc[result$variable == "annual_family_income"], 4)
  
  # Weighted mean calculations (manual check)
  wh_income <- weighted.mean(c(10, 20, 30, 40), c(1, 2, 3, 5))
  wf_income <- weighted.mean(c(15, 25, 35, 45), c(1, 2, 3, 4))
  expect_equal(result$wmean[result$variable == "annual_household_income"], wh_income)
  expect_equal(result$wmean[result$variable == "annual_family_income"], wf_income)
  
  # Check confidence intervals are numeric and non-negative
  expect_true(all(result$ci >= 0 | is.na(result$ci)))
})