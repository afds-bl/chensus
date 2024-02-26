test_that("Size 1 stratum works", {
  a <- 3.5
  data <- data.frame(weights = a, strata = 34)
  expect_equal(
    se_estimate(data = data, weight = "weights", strata = "strata"),
    tibble(total = a, vhat = 0, occ = 1L, stand_dev = 0, ci = 0, ci_per = 0)
  )
})
