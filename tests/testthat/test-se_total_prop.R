test_that("se_total_prop works with numeric variable by treating it as categorical", {
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    category = rep(c(1, 2), each = 5)
  )
  
  expect_silent({
    result <- se_total_prop(df, category, weight = weight)
    expect_s3_class(result, "data.frame")
    expect_true(all(c("1", "2") %in% result$category))
  })
  
  expect_error(
    {
      se_total_prop(df, notacolumn, weight = weight)
    },
    regexp = "don't exist"
  )
})
