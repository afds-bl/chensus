test_that("se_summarise computes mh and Nh correctly per stratum", {
  
  # Sample data
  df <- tibble(
    zone = c("A", "A", "B", "B", "A", "B", "A", "B", "A", "B"),
    weight = c(1.1, 1.4, 2.0, 0.9, 1.6, 2.2, 1.3, 1.8, 1.0, 2.5),
    score = c(10, 12, 9, 11, 8, 14, 7, 13, 10, 15),
    group = c("G1", "G1", "G2", "G2", "G1", "G2", "G1", "G2", "G1", "G2"),
    category = rep(c("X", "Y"), each = 5)
  )

  # Expected output
  expected <- df %>%
    group_by(zone) %>%
    mutate(mh = n()) %>%
    mutate(Nh = sum(weight)) %>%
    ungroup() %>%
    distinct(zone, mh, Nh) %>%
    arrange(zone)
  
  # Actual result from the function
  result <- se_summarise(df, weight = "weight", strata = "zone") %>%
    distinct(zone, mh, Nh) %>%
    arrange(zone)
  
  expect_equal(result, expected)
})
