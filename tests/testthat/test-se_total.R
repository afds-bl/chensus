test_that("se_total computes population total and CI correctly", {
 
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )
  
  result <- se_total(
    data = df,
    weight = "weight",
    strata = "zone",
    group_vars = "group",
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
      result <- se_estimate_total(data = df, weight = "weight"),
      "se_total.*deprecated"
    )
    expect_s3_class(result, "data.frame")
  })
  
})

test_that("se_total works with deprecated argument `condition`", {
  df <- data.frame(
    zone = rep(c("A", "B"), each = 5),
    weight = c(10, 12, 11, 13, 14, 8, 9, 10, 9, 11),
    group = rep(c("X", "Y"), times = 5)
  )
  
  expect_warning(
    result <- se_total(
      data = df,
      weight = "weight",
      strata = "zone",
      condition = "group",  # deprecated argument
      alpha = 0.05
    ),
    regexp = "condition.*deprecated"
  )
  
  expect_s3_class(result, "data.frame")
  expect_true("group" %in% names(result))
})
