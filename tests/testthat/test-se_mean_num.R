test_that("se_mean_num computes mean and CI correctly", {
  # Sample data
  df <- tibble::tibble(
    zone = c("A", "A", "B", "B", "B"),
    weight = c(1.2, 0.8, 1, 1.5, 0.5),
    score = c(10, 12, 8, 9, 11),
    group = c("G1", "G1", "G2", "G2", "G2")
  )
  
  # Run function
  result <- se_mean_num(data = df, variable = "score", condition = "group", strata = "zone", weight = "weight")
  
  # Check structure
  expect_s3_class(result, "data.frame")
  expect_true(all(c("average", "stand_dev", "ci") %in% names(result)))
  
  # Check numeric outputs
  expect_true(all(result$average > 0))
  expect_true(all(result$stand_dev >= 0))
  expect_true(all(result$ci >= 0))
})

test_that("se_mean_num throws error for non-numeric variable", {
  df <- tibble::tibble(
    zone = c("A", "B"),
    weight = c(1, 2),
    text_var = c("x", "y")
  )
  expect_error(
    se_mean_num(data = df, variable = "text_var", weight = "weight"),
    "Variable must be numeric."
  )
})
