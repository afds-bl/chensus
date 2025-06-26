test_that("ogd_wrapper produces valid output for se_total", {
  test_data <- tibble::tibble(
    gender = c("Male", "Female", "Female", "Male"),
    height = c("tall", "tall", "short", "medium"),
    zone = c("A", "A", "B", "B"),
    weights = c(1.5, 2.0, 1.0, 1.2)
  )
  
  strata <- rlang::sym("zone")
  weights <- rlang::sym("weights")

  result <- se_ogd_wrapper(
    data = test_data,
    # core_fun = dummy_se_total,
    core_fun = se_total,
    strata = strata,
    weight = weights,
    gender, height
  )
  
  expect_s3_class(result, "tbl_df")
  expect_true("total" %in% names(result))
  expect_true("gender" %in% names(result))
  expect_true(any(result$gender == "Total"))
  expect_true(any(result$height == "Total"))
  expect_gt(nrow(result), 6)  # Total + gender + height
})
