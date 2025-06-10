test_that("se_total_map works with multiple grouping variables in parallel", {
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )

  # Run se_total_map with two grouping variables
  result <- se_total_map(
    data = df,
    weight = weight,
    strata = zone,
    group, category
  )

  # Expected columns
  expected_cols <- c(
    "variable", "value", "occ", "total", "vhat", "stand_dev", "ci", "ci_per"
  )

  # Check output type and columns
  expect_s3_class(result, "data.frame")
  expect_true(all(expected_cols %in% names(result)))

  # Check that all grouping variables are present in the 'variable' column
  expect_true(all(c("group", "category") %in% unique(result$variable)))

  # Check that totals and variances are non-negative
  expect_true(all(result$total >= 0))
  expect_true(all(result$vhat >= 0))

  # Check that the number of rows matches the sum of unique levels in each grouping variable
  n_group <- length(unique(df$group))
  n_category <- length(unique(df$category))
  expect_equal(nrow(result), n_group + n_category)
})
