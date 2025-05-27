test_that("se_dummy creates correct dummy variables for a categorical column", {
  # Minimal test input
  test_data <- data.frame(
    id = 1:2,
    gender = c("Male", "Female"),
    stringsAsFactors = FALSE
  )
  
  # Expected output
  expected <- data.frame(
    id = 1:2,
    gender = c("Male", "Female"),
    gender_Male = c(1L, 0L),
    gender_Female = c(0L, 1L)
  )
  
  # Actual result from the function
  result <- se_dummy(test_data, column = "gender", id = "id") |>
    dplyr::select(id, gender, starts_with("gender_"))
  
  # Comparison
  expect_equal(result, expected, ignore_attr = TRUE)
})