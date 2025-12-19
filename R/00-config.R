## 00-config.R
## Library policy: system + dev (via environment variable)

.myRlib <- Sys.getenv("MY_R_DEVLIB", unset = NA_character_)

if (is.na(.myRlib) || !nzchar(.myRlib)) {
  stop(
    "Environment variable MY_R_DEVLIB is not set.\n",
    "Define it in ~/.Renviron, e.g.:\n",
    "MY_R_DEVLIB=~/Dropbox/Boulot/dev/r/myRlib"
  )
}

.myRlib <- path.expand(.myRlib)

## Ensure dev library exists
dir.create(.myRlib, recursive = TRUE, showWarnings = FALSE)

## Enforce library order:
## 1) system library (.Library)
## 2) dev library (.myRlib)
.libPaths(c(.Library, .myRlib))
