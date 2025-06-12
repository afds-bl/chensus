# dev/setup.R
# One-time setup script for chensus package development
# !! Run interactively, not sourced !!

usethis::use_description()                    # Create DESCRIPTION if not present
usethis::use_namespace()                      # Create NAMESPACE if not present
usethis::use_mit_license()                    # Adjust license/author as needed
usethis::use_roxygen_md()                     # Use markdown in roxygen docs
usethis::use_package_doc()                    # Create R/chensus-package.R
usethis::use_readme_rmd()                     # Create README.Rmd
usethis::use_news_md()                        # Create NEWS.md

# Version control & GitHub
usethis::use_git()
usethis::use_github(protocol = "https")       # or "ssh" if preferred

# Tests
usethis::use_testthat()
usethis::use_test("basic")                    # Sample test file

# Vignettes
usethis::use_vignette("Method")
usethis::use_vignette("chensus")

# Dependencies (adjust as needed)
usethis::use_package("dplyr", type = "Imports")
usethis::use_package("purrr", type = "Imports")
usethis::use_package("stringr", type = "Imports")
usethis::use_package("testthat", type = "Suggests")
usethis::use_package("pkgdown.offline", type = "Suggests")  # Local-only pkgdown alternative

# Build ignore dev folder
usethis::use_build_ignore("dev")

# CI/CD
usethis::use_github_action("check-standard")  # Standard R CMD check workflow

# Optionally: Add pkgdown configuration (even if you won’t use pkgdown::build_site() directly)
usethis::use_pkgdown()                        # Creates _pkgdown.yml (edit manually if needed)

# Use manual vignette rendering if proxy blocks normal build
rmarkdown::render("vignettes/Method.Rmd", output_dir = "inst/doc")
rmarkdown::render("vignettes/chensus.Rmd", output_dir = "inst/doc")

# Optional: Local site build using pkgdown.offline
# pkgdown.offline::build_site()               # If configured

message("Setup complete. Commit dev/setup.R but do not include it in R/")