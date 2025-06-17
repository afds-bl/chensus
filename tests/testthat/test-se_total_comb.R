test_that("se_total_comb returns correct structure and content", {
  df <- nhanes
  result <- se_total_comb(df, strata = strata, weight = weights, gender, birth_country)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("gender", "birth_country", "total") %in% names(result)))
  expect_true("Total" %in% unique(result$gender))
  expect_true("Total" %in% unique(result$birth_country))
  expect_gt(nrow(result), length(unique(result$gender)))
  expect_gt(nrow(result), length(unique(result$birth_country)))
})

test_that("se_combn returns all combinations of input vars", {
  input <- c("x", "y")
  result <- se_combn(input)

  expect_type(result, "list")
  expect_true(any(vapply(result, identical, logical(1), character(0))))
  expect_true(any(vapply(result, identical, logical(1), "x")))
  expect_true(any(vapply(result, identical, logical(1), "y")))
  expect_true(any(vapply(result, identical, logical(1), c("x", "y"))))
})
