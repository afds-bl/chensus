test_that("se_prop_ogd returns correct structure and content", {
  df <- nhanes
  result <- se_prop_ogd(df, strata = strata, weight = weights, gender, birth_country)
  
  expect_s3_class(result, "data.frame")
  expect_true(all(c("gender", "birth_country", "occ", "prop", "vhat", "stand_dev", "ci", "ci_l", "ci_u") %in% names(result)))
  expect_true("Total" %in% unique(result$gender))
  expect_true("Total" %in% unique(result$birth_country))
  expect_gt(nrow(result), length(unique(result$gender)))
  expect_gt(nrow(result), length(unique(result$birth_country)))
  expect_true(all(result$prop >= 0 & result$prop <= 1))
})

test_that("se_prop_ogd uses default strata and handles numeric variables", {
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    size = c(1, 1, 2, 2, 2, 2, 1, 2, 1, 1)
  )
  
  result <- se_prop_ogd(data = df, weight = weight, size, alpha = 0.1)
  expect_true(is.factor(result$size))
  expect_true(all(c("size", "occ", "prop", "vhat", "stand_dev", "ci", "ci_l", "ci_u") %in% names(result)))

  expect_error(
    se_prop_ogd(df, weight = weight, "not_a_column"),
    regexp = "doesn't exist" 
  )
})

test_that("se_prop_ogd works with no grouping columns", {
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5)
  )
  
  result <- se_prop_ogd(df, weight = weight)
  expect_true(all(c("occ", "prop", "vhat", "stand_dev", "ci", "ci_l", "ci_u") %in% names(result)))
  expect_equal(nrow(result), 1)
  expect_true(all(result$prop == 1))
})
