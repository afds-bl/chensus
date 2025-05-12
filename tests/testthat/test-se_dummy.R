test_that("basic dummy works", {
  expect_equal(
  data.frame(gender = c("Male", "Female"), gender_Male = c(1L, 0L), gender_Female = c(0L, 1L)),
    nhanes |>
    dplyr::mutate(id = row_number()) |>
    se_dummy(column = "gender", id = "id") |>
      dplyr::distinct(pick(starts_with("gender"))) |>
    mutate(gender = as.character(gender)),
    ignore_attr = TRUE
  )
})
