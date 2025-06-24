test_that("se_dummy handles both quoted and unquoted column names", {
  # Test data
  df <- data.frame(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9)
  )

  # Expected output
  expected <- tibble::tibble(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9),
    joint_A_9 = c(0L, 0L, 1L),
    joint_A_10 = c(1L, 0L, 0L),
    joint_B_5 = c(0L, 1L, 0L)
  )

  # Test both input types
  test_cases <- list(
    unquoted = rlang::expr(group),
    quoted = "group",
    symbol_from_string = rlang::sym("group")
  )
  
  expected <-  tibble::tibble(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9),
    joint_A = c(1L, 0L, 1L),
    joint_B = c(0L, 1L, 0L)
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
      names(result)[4:5],
      c("joint_A", "joint_B"),
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
    regexp = "doesn't exist"
  )
})
