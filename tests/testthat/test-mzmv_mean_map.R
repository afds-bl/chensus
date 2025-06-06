test_that("mzmv_mean_map works with NULL and specified group_vars", {
  df <- tibble(
    annual_household_income = c(10, 20, 30, 40),
    household_size = c(2, 1, 4, 3),
    gender = c("M", "F", "M", "F"),
    region = c("North", "South", "North", "South"),
    weights = c(1, 2, 3, 4)
  )
  
  # # Test with NULL group_vars (should add dummy group "all")
  # result1 <- mzmv_mean_map(
  #   data = df,
  #   variable = c("annual_household_income", "household_size"),
  #   weight = "weights"
  # )
  # 
  # expect_true(all(c("variable", "group_vars", "group_vars_value", "nc", "wmean", "ci") %in% colnames(result1)))
  # expect_equal(unique(result1$group_vars_value), "all")
  # 
  # # Test with one group_var
  # result2 <- mzmv_mean_map(
  #   data = df,
  #   variable = c("annual_household_income", "household_size"),
  #   group_vars = "gender",
  #   weight = "weights"
  # )
  # 
  # expect_true(all(c("variable", "group_vars", "group_vars_value", "nc", "wmean", "ci") %in% colnames(result2)))
  # expect_equal(sort(unique(result2$group_vars_value)), sort(unique(df$gender)))
  # 
  # # Test with multiple group_vars
  # result3 <- mzmv_mean_map(
  #   data = df,
  #   variable = c("annual_household_income", "household_size"),
  #   group_vars = c("gender", "region"),
  #   weight = "weights"
  # )
  # 
  # expect_true(all(c("variable", "group_vars", "group_vars_value", "nc", "wmean", "ci") %in% colnames(result3)))
  # expect_true(all(result3$group_vars %in% c("gender", "region")))
  # 
  # # Check counts are positive integers
  # expect_true(all(result3$nc > 0))
})