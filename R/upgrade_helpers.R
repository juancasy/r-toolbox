## upgrade_helpers.R
## Save/restore CRAN package list for R upgrades

save_cran_list <- function(file = "~/cran_pkgs_before_upgrade.rds", lib = get_syslib()) {
  ip <- as.data.frame(installed.packages(lib.loc = lib), stringsAsFactors = FALSE)

  ## Keep only non-base/non-recommended
  pr <- ip$Priority
  keep <- is.na(pr) | !(pr %in% c("base", "recommended"))

  pkgs <- sort(unique(ip$Package[keep]))
  saveRDS(pkgs, file)
  invisible(pkgs)
}

restore_cran_list <- function(file = "~/cran_pkgs_before_upgrade.rds", lib = get_syslib(), ...) {
  pkgs <- readRDS(file)
  install.packages(pkgs, lib = lib, ...)
  invisible(pkgs)
}
