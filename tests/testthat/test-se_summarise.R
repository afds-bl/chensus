test_that("basic summary works", {
  expect_equal(
    nhanes |>
      add_count(strata, name = "mh") |>
      count(strata, mh, wt = weights, name = "Nh"),
    se_summarise(nhanes, weight = "weights", strata = "strata") |>
      distinct(strata, mh, Nh) |>
      arrange(strata),
    ignore_attr = TRUE
  )
})
