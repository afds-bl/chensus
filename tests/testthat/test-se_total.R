test_that("se_total works with various argument styles", {
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )

  # Unquoted argument test (default zone)
  res1 <- se_total(data = df, !!sym("group"), weight = weight)
  expect_s3_class(res1, "data.frame")
  expect_true(all(c("group", "occ", "total", "vhat", "stand_dev", "ci", "ci_per") %in% names(res1)))

  # Quoted arguments test
  res2 <- se_total(data = df, !!sym("group"), weight = "weight", strata = "zone")
  expect_s3_class(res2, "data.frame")
  expect_true(all(c("group", "occ", "total", "vhat", "stand_dev", "ci", "ci_per") %in% names(res2)))

  # Programmatic test
  g <- "group"
  w <- "weight"
  s <- "zone"
  res3 <- se_total(data = df, !!!syms(g), weight = !!sym(w), strata = !!sym(s))
  expect_s3_class(res3, "data.frame")
  expect_true(all(c("group", "occ", "total", "vhat", "stand_dev", "ci", "ci_per") %in% names(res3)))

  # Check value types and sanity
  for (res in list(res1, res2, res3)) {
    expect_type(res$total, "double")
    expect_type(res$ci, "double")
    expect_true(all(res$total > 0))
    expect_true(all(res$ci >= 0))
  }
})

test_that("se_estimate_total still works (deprecated)", {
  df <- tibble(
    zone = c("A", "A", "B", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9),
    score = c(10, 12, 9, 11)
  )
  expect_warning(
    result <- se_estimate_total(data = df, weight = weight),
    "se_total.*deprecated"
  )
  expect_s3_class(result, "data.frame")
})
