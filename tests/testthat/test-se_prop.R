test_that("se_prop computes mean and CI of categorical input correctly with various argument types", {
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )

  # Case 1: Unquoted
  res_unquoted <- se_prop(df, category, group, weight = weight)

  # Case 2: Quoted
  res_quoted <- se_prop(df, "category", "group", weight = "weight")

  # Case 3: Programmatic
  v <- c("category", "group")
  w <- "weight"
  res_prog <- se_prop(df, !!!syms(v), weight = !!sym(w))

  for (res in list(res_unquoted, res_quoted, res_prog)) {
    expect_s3_class(res, "data.frame")
    expect_true(all(c("occ", "prop", "vhat", "stand_dev", "ci", "ci_l", "ci_u") %in% names(res)))
    expect_true(all(res$prop >= 0 & res$prop <= 1))
    expect_true(all(res$stand_dev >= 0))
    expect_true(all(res$ci >= 0))
  }
})

test_that("se_prop works with numeric variable by treating it as categorical", {
  df <- tibble(
    zone = c("A", "B"),
    weight = c(1, 2),
    category = c(1, 2)
  )

  expect_silent({
    result <- se_prop(df, category, weight = weight)
    expect_s3_class(result, "data.frame")
    expect_true(all(c("1", "2") %in% result$category))
  })

  expect_error(
    {
      se_prop(df, notacolumn, weight = weight)
    },
    regexp = "don't exist"
  )
})

test_that("se_prop handles no column input correctly", {

    df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5)
  )
  
  result <- se_prop(df, weight = weight)
  
  # Verify results
  expect_equal(nrow(result), 1)
  expect_equal(result$occ, 10L)
  expect_equal(result$prop, 1)
  expect_equal(result$vhat, 0)
  expect_equal(result$stand_dev, 0)
  expect_equal(result$ci, 0)
  expect_equal(result$ci_l, 1)
  expect_equal(result$ci_u, 1)
})
