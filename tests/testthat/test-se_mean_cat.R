test_that("se_mean_cat computes mean and CI of categorical input correctly", {
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )

  # Run the function
  result <- se_mean_cat(
    data = df,
    variable = "category",
    group_vars = "group",
    strata = "zone",
    weight = "weight"
  )

  # Check structure
  expect_s3_class(result, "data.frame")
  expect_true(all(c("dummy_var", "average", "stand_dev", "ci") %in% names(result)))

  # One row per dummy variable * group_vars group
  expect_equal(length(unique(result$dummy_var)), 2)
  expect_true(all(result$average >= 0 & result$average <= 1))
  expect_true(all(result$stand_dev >= 0))
  expect_true(all(result$ci >= 0))
})

test_that("se_mean_cat errors with non-categorical input", {
  df <- tibble::tibble(
    zone = c("A", "B"),
    weight = c(1, 2),
    category = c(1, 2)
  )

  expect_error(
    {
      se_mean_cat(df, variable = "notacolumn", weight = "weight")
    },
    regexp = "Can't subset elements that don't exist"
  )
})
