test_that("basic summary works", {
  expect_equal(
    nhanes |>
      summarise(average = weighted.mean(age, w = weights), .by = gender),
    se_estimate_mean(
      data = nhanes,
      variable = "age",
      var_type = "num",
      weight = "weights",
      strata = "strata",
      condition = "gender"
      ) |>
      select(gender, average),
    ignore_attr = TRUE
  )
})
