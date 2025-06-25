test_that("se_total_prop_ogd returns expected structure", {
  skip_if_not_installed("dplyr")
  skip_if_not_installed("forcats")
  
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )
  
  result <- se_total_prop_ogd(data = df, weight = weight, group, category)

  # Check that the result is a tibble/data.frame
  expect_s3_class(result, "data.frame")
  
  # Expected columns (example based on typical output structure)
  expected_cols <- c("group", "category", "total", "prop", "ci_total", "ci_prop")
  expect_true(all(expected_cols %in% names(result)))
  
  # Ensure "Total" level is present for each grouping variable
  expect_true("Total" %in% unique(as.character(result$group)))
  expect_true("Total" %in% unique(as.character(result$category)))
  
  # Check that confidence interval is valid
  expect_true(all(result$ci_l_prop <= result$prop & result$prop <= result$ci_u_prop, na.rm = TRUE))
  
})
