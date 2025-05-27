test_that("deprecated wrappers issue warnings and call new functions", {
  
  # se_estimate_mean
  expect_warning(
    se_estimate_mean(data = nhanes, variable = "family_size", weight = "weights", strata = "strata"),
    regexp = "deprecated"
  )
  
  # mzmv_mean
  expect_warning(
    mzmv_estimate_mean(data = nhanes, variable = "household_size", weight = "weights"),
    regexp = "deprecated"
  )
  
  # mzmv_mean_map
  expect_warning(
    mzmv_estimate_mean_map(data = nhanes, variable = "household_size", weight = "weights"),
    regexp = "deprecated"
  )

})
     
