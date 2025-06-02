test_that("se_dummy creates correct dummy variables for a categorical column", {
  # Sample data
  df <- data.frame(
    id = 1:4,
    group = c("A", "B", "A", "C")
  )
  
  # Expected output
  expected <- data.frame(
    id = 1:4,
    group = c("A", "B", "A", "C"),
    group_A = c(1L, 0L, 1L, 0L),
    group_B = c(0L, 1L, 0L, 0L),
    group_C = c(0L, 0L, 0L, 1L)
  )

  # Actual result from the function
  result <- se_dummy(df, column = group)
  
  # Comparison
  expect_equal(result, expected, ignore_attr = TRUE)
})
