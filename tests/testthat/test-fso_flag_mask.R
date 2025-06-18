test_that("fso_flag_mask masks correctly and assigns obs_status by language", {
  data <- tibble::tibble(
    occ = c(3, 10, 60),
    value = c(100, 200, 300)
  )

  # Test German (default)
  result_de <- fso_flag_mask(data, "de")
  expect_equal(result_de$obs_status, c(
    confidential = "Kein Sch\u00e4tzwert (vertraulich)",
    low = "Sch\u00e4tzwert bedingt verl\u00e4sslich",
    reliable = "Sch\u00e4tzwert verl\u00e4sslich"
  ))
  expect_true(is.na(result_de$value[1]))
  expect_equal(result_de$value[2:3], c(200, 300))

  # Test English
  result_en <- fso_flag_mask(data, "en")
  expect_equal(result_en$obs_status, c(
    confidential = "No estimate (confidential)",
    low = "Estimate of low reliability",
    reliable = "Reliable estimate"
  ))
})

test_that("fso_flag_mask stops if 'occ' is missing", {
  data <- tibble::tibble(x = 1:3)
  expect_error(fso_flag_mask(data), "must contain an 'occ' column")
})

test_that("fso_flag_mask handles all numeric columns", {
  data <- tibble::tibble(
    occ = c(2, 50),
    val1 = c(10, 20),
    val2 = c(100, 200)
  )
  result <- fso_flag_mask(data, "en")
  expect_true(all(is.na(result[1, c("val1", "val2")])))
  expect_equal(result[2, c("val1", "val2")], tibble::tibble(val1 = 20, val2 = 200))
})
