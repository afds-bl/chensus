test_that("se_total_prop works with numeric variable by treating it as categorical", {
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    category = rep(c(1, 2), each = 5)
  )
  
  # Test no grouping column ----
  result <- se_total_prop(df, weight = weight)
  result_total <- se_total(df, weight = weight)
  
  # Verify results
  expect_equal(nrow(result), 1)
  expect_equal(result$occ, 10L)
  expect_equal(result$total, result_total$total)
  expect_equal(result$ci_total, result_total$ci)
  expect_equal(result$ci_l_total, result_total$ci_l)
  expect_equal(result$ci_u_total, result_total$ci_u)
  expect_equal(result$prop, 1)
  expect_equal(result$ci_prop, 0)
  expect_equal(result$ci_l_prop, 1)
  expect_equal(result$ci_u_prop, 1)
  
  # Test one grouping column ----
  expect_silent({
    result <- se_total_prop(df, category, weight = weight)
    expect_s3_class(result, "data.frame")
    expect_true(all(c("1", "2") %in% result$category))
  })
  
  # Test non-exiting column
  expect_error(
    {
      se_total_prop(df, notacolumn, weight = weight)
    },
    regexp = "don't exist"
  )
})
