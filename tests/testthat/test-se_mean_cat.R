test_that("se_mean_cat computes mean and CI of categorical input correctly with various argument types", {
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )

  # Case 1: Unquoted
  res_unquoted <- se_mean_cat(df, variable = category, weight = weight, group)

  # Case 2: Quoted
  res_quoted <- se_mean_cat(df, variable = "category", weight = "weight", "group")

  # Case 3: Programmatic
  v <- "category"
  w <- "weight"
  g <- "group"
  res_prog <- se_mean_cat(df, variable = !!sym(v), weight = !!sym(w), !!!syms(g))

  for (res in list(res_unquoted, res_quoted, res_prog)) {
    expect_s3_class(res, "data.frame")
    expect_true(all(c("occ", "prop", "vhat", "stand_dev", "ci", "ci_l", "ci_u") %in% names(res)))
    expect_true(all(res$prop >= 0 & res$prop <= 1))
    expect_true(all(res$stand_dev >= 0))
    expect_true(all(res$ci >= 0))
  }
})

test_that("se_mean_cat works with numeric variable by treating it as categorical", {
  df <- tibble(
    zone = c("A", "B"),
    weight = c(1, 2),
    category = c(1, 2)
  )

  expect_silent({
    result <- se_mean_cat(df, variable = category, weight = weight)
    expect_s3_class(result, "data.frame")
    expect_true(all(c("1", "2") %in% result$category))
  })

  expect_error(
    {
      se_mean_cat(df, variable = notacolumn, weight = weight)
    },
    regexp = "don't exist"
  )
})
