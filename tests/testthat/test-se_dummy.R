test_that("se_dummy handles both quoted and unquoted column names", {
  # Test data
  df <- data.frame(
    id = 1:4,
    group = c("A", "B", "A", "C")
  )
  
  # Expected output
  expected <- tibble::tibble(
    id = 1:4,
    group = c("A", "B", "A", "C"),
    group_A = c(1L, 0L, 1L, 0L),
    group_B = c(0L, 1L, 0L, 0L),
    group_C = c(0L, 0L, 0L, 1L)
  )
  
  # Test both input types
  test_cases <- list(
    unquoted = rlang::expr(group),
    quoted = "group",
    symbol_from_string = rlang::sym("group")
  )
  
  for (case_name in names(test_cases)) {
    # Force evaluation of the test case
    column <- test_cases[[case_name]]
    
    # Test basic functionality
    result <- se_dummy(df, !!column)
    expect_equal(
      as.data.frame(result),
      as.data.frame(expected),
      ignore_attr = TRUE,
      info = paste("Case:", case_name)
    )
    
    # Test column ordering
    expect_equal(
      names(result)[3:5],
      c("group_A", "group_B", "group_C"),
      info = paste("Column ordering - Case:", case_name)
    )
    
    # Test preservation of original data
    expect_equal(
      result[c("id", "group")],
      df[c("id", "group")],
      info = paste("Data preservation - Case:", case_name)
    )
  }
  
  # Test invalid column name
  expect_error(
    {
      se_dummy(df, "nonexistent_column")
      },
    regexp = "Can't subset elements that don't exist"
  )
})
