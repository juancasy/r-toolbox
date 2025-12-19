## install_helpers.R
## Helpers for installing packages consistently

get_syslib <- function() .Library
get_devlib <- function() .myRlib

install_cran <- function(pkgs, ..., lib = get_syslib()) {
  install.packages(pkgs, lib = lib, ...)
}

install_my <- function(path = ".", ..., lib = get_devlib(), upgrade = "never") {
  ## Ensure devtools exists (installed to system library in this policy)
  if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools", lib = get_syslib())
  }
  devtools::install(path = path, lib = lib, upgrade = upgrade, ...)
}
