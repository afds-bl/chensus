summarise_pop_cens_strata <- function(data, strata_var, weight_var, mh_col, Nh_col){
  data %>%
    group_by(across(all_of(strata_var))) %>%
    summarise({{mh_col}} := n(), # number of participants per stratum
              {{Nh_col}} := sum(.data[[weight_var]])) %>% # Total of weights per stratum = total population size for the canton
    left_join(data, ., by = strata_var)
}
