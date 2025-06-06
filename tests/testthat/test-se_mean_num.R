test_that("se_mean_num computes mean and CI correctly with different argument types", {
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )
  
  # Unquoted column names
  res_unquoted <- se_mean_num(data = df, variable = score, weight = weight, group, category)
  
  # Quoted arguments
  res_quoted <- se_mean_num(data = df, variable = "score", weight = "weight", "group", "category")
  
  # Programmatic use
  v <- "score"
  w <- "weight"
  groups <- c("group", "category")
  res_prog <- se_mean_num(
    data = df,
    variable = !!sym(v),
    weight = !!sym(w),
    !!!syms(groups)
  )
  
  # Extract expected column name
  var_name <- "score"
  
  for (res in list(res_unquoted, res_quoted, res_prog)) {
    # Check structure
    expect_s3_class(res, "data.frame")
    expect_true(all(c(var_name, "stand_dev", "ci", "ci_l", "ci_u") %in% names(res)))
    
    # Check numeric outputs
    expect_type(res[[var_name]], "double")
    expect_true(all(res[[var_name]] > 0))
    expect_true(all(res$stand_dev >= 0))
    expect_true(all(res$ci >= 0))
  }
})

test_that("se_mean_num throws error for non-numeric variable", {
  df <- tibble(
    zone = c("A", "B"),
    weight = c(1, 2),
    text_var = c("x", "y")
  )
  expect_error(
    se_mean_num(data = df, variable = text_var, weight = weight),
    "must be numeric"
  )
})
