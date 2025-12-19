## diagnostics.R
## Quick checks to validate your setup

check_setup <- function(test_pkg = "cli") {
  cat("=== R setup check (system + dev) ===\n")
  cat("R version:  ", as.character(getRversion()), "\n", sep = "")
  cat("Platform:   ", R.version$platform, "\n", sep = "")
  cat("RStudio:    ", if (nzchar(Sys.getenv("RSTUDIO"))) "yes" else "no", "\n", sep = "")

  cat("\n.libPaths():\n")
  print(.libPaths())

  cat("\nSystem library (.Library):\n  ", .Library, "\n", sep = "")
  cat("Write access (.Library):  ", file.access(.Library, 2), "  (0 = writable)\n", sep = "")

  cat("\nDev library (.myRlib):\n  ", .myRlib, "\n", sep = "")
  cat("Write access (devlib):    ", file.access(.myRlib, 2), "  (0 = writable)\n", sep = "")

  cat("\nTest package location:\n")
  if (requireNamespace(test_pkg, quietly = TRUE)) {
    cat("  ", test_pkg, " -> ", find.package(test_pkg), "\n", sep = "")
  } else {
    cat("  ", test_pkg, " is not installed.\n", sep = "")
  }

  invisible(TRUE)
}

