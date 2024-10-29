test_that("stratum size 1 works", {
  nhanes_na <- nhanes |>
    mutate(
      household_size = replace(
        household_size,
        sample(row_number(), size = ceiling(0.3 * n()), replace = FALSE), NA
      ),
      .by = strata
    )
  expect_equal(mzmv_estimate_mean(data = nhanes_na |> filter(is.na(household_size)),
                                  variable = "household_size",
                                  weight = "weights"),
               data.frame(variable = "household_size", nc = 0, wmean = NA_real_, ci = NA_real_))
})

test_that("stratum size > 1 works", {
  cf <- 1.14
  alpha <- 0.1
  out <- nhanes |>
    summarise(
      nc = n(),
      wmean = sum(weights * household_size) / sum(weights),
      ci = cf * sqrt(sum(weights * (household_size - wmean)^2) / (sum(weights) - 1) / n()) * qnorm(1 - alpha / 2)) |>
    mutate(variable = "household_size", .before = 1)
  expect_equal(mzmv_estimate_mean(data = nhanes, variable = "household_size", weight = "weights"),
               out)
})

test_that("mzmv_estimate_mean_map equivalent to mzmv_estimate_mean with no conditions", {
  out1 <- mzmv_estimate_mean(data = nhanes, variable = "household_size", weight = "weights") |>
    as_tibble()
  out2 <- mzmv_estimate_mean_map(data = nhanes, variable = "household_size", weight = "weights") |>
    select(-starts_with("condition"))
  expect_equal(out1, out2)
})
