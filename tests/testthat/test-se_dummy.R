test_that("se_dummy handles all cases including no columns", {
  # Test data
  df <- data.frame(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9)
  )
  
  # Test 1: No columns provided
  result_none <- se_dummy(df)
  expected_none <- data.frame(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9),
    joint_total = 1
  )
  expect_equal(result_none, expected_none)
  
  # Test 2: Single column provided
  result_single <- se_dummy(df, group)
  expected_single <- data.frame(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9),
    joint_A = c(1L, 0L, 1L),
    joint_B = c(0L, 1L, 0L)
  )
  expect_equal(result_single, expected_single)
  
  # Test 3: Multiple columns provided
  result_multi <- se_dummy(df, group, team)
  expected_multi <- data.frame(
    id = 1:3,
    group = c("A", "B", "A"),
    team = c(10, 5, 9),
    joint_A_9 = c(0L, 0L, 1L),
    joint_A_10 = c(1L, 0L, 0L),
    joint_B_5 = c(0L, 1L, 0L)
  )
  expect_equal(result_multi, expected_multi)
  
  # Test 4: Non-existent column (error case)
  expect_error(
    {
      se_dummy(df, nonexistent_column)
    },
    regexp = "doesn't exist"
  )
})