# From the CLI: 
# make            # Build docs + install
# make test       # Run tests
# make data       # Recreate datasets
# make check      # Run checks


# Default task
all: document install

# Generate Rd files and NAMESPACE
document:
	Rscript -e "devtools::document()"

# Install the package
install:
	Rscript -e "devtools::install(upgrade = 'never')"

# Run unit tests
test:
	Rscript -e "devtools::test()"

# Rebuild data (run scripts in data-raw/)
data:
	Rscript data-raw/prepare_nhanes.R

# Run all checks (CRAN-like)
check:
	Rscript -e "devtools::check()"

# Clean auto-generated files
clean:
	rm -rf man/ NAMESPACE chensus.Rcheck *.tar.gz

# View package documentation
docs:
	Rscript -e "devtools::load_all(); help(package = 'chensus')"

.PHONY: all document install test data check clean docs
