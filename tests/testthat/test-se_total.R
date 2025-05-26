test_that("se_estimate_total computes population total and CI correctly", {
  
  # Simulate minimal test dataset
  test_data <- data.frame(
    zone = rep(c("A", "B"), each = 5),
    weight = c(10, 12, 11, 13, 14, 8, 9, 10, 9, 11),
    group = rep(c("X", "Y"), times = 5)
  )
  
  result <- se_estimate_total(
    data = test_data,
    weight = "weight",
    strata = "zone",
    condition = "group",
    alpha = 0.05
  )
  
  # Check structure
  expect_s3_class(result, "data.frame")
  expect_true(all(c("group", "occ", "total", "vhat", "stand_dev", "ci", "ci_per") %in% names(result)))
  
  # Check types
  expect_type(result$total, "double")
  expect_type(result$ci, "double")
  
  # Basic value checks (within reasonable bounds)
  expect_true(all(result$total > 0))
  expect_true(all(result$ci >= 0))
  
  # Check deprecated still works
  test_that("se_estimate_total still works (deprecated)", {
    expect_warning(
      result <- se_estimate_total(data = test_data, weight = "weight"),
      "se_estimate_total.*deprecated"
    )
    expect_s3_class(result, "data.frame")
  })
  
})
