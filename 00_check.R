library(usethis)
library(devtools)

# # Add tests
# use_testthat(3)
# use_test("se_estimate")
# use_test("se_summarise")
# use_test("mzmv_estimate")

# Build package

load_all()

document()
check_man()

check()

build()

test()

check()

install()

use_version(which = "minor", push = FALSE)

# To add dependencies
use_package("tidyr")
use_package("dplyr")
use_package("purrr")
use_tidy_description()
