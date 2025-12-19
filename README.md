Toolbox for R package management on macOS
================

<!-- README.md is generated from README.Rmd. Please edit README.Rmd -->

## Foreword

This repository documents a lightweight toolbox for managing R packages
on macOS. It presents a **clear and explicit strategy** for separating
CRAN packages from user-developed packages, with an emphasis on
reproducibility, transparency, and long-term maintainability.

This setup is shared as a **personal choice** for convenience that may
serve as an inspiration.

------------------------------------------------------------------------

## Overview

For users who develop R packages over long periods of time, it is often
useful to distinguish clearly between:

1.  **System library** (`.Library`)
    - R base and recommended packages
    - CRAN packages
2.  **Development library** (custom path)
    - Packages under active development

The design goals of this toolbox are:

- Minimal complexity at R/RStudio startup
- Explicit control over package installation paths
- No implicit behaviour or silent fallbacks
- A reproducible workflow for R upgrades
- No dependency on external repositories at startup

This setup assumes that the **system library is writable**, as is the
case for the standard macOS Framework installation of R.

------------------------------------------------------------------------

## Repository structure

This repository includes the helper scripts used by the toolbox, stored
under a top-level `/R/` directory (similar to an R package layout,
although this is *not* a package).

    r-toolbox/
    ├─ README.Rmd
    └─ R/
       ├─ 00-config.R
       ├─ install_helpers.R
       ├─ upgrade_helpers.R
       └─ diagnostics.R

These files are intended to be copied to a local configuration directory
in the user environment.

------------------------------------------------------------------------

## Library policy

At startup, the following library order is enforced:

``` r
.libPaths()
```

Expected result:

``` text
[1] /Library/Frameworks/R.framework/Versions/<R-version>/Resources/library
[2] <DEV_LIBRARY>
```

Meaning:

- **System library** (`.Library`)
  - Base and recommended packages
  - All CRAN packages
- **Development library**
  - User-developed packages only

No user library (`R_LIBS_USER`) is used in `.libPaths()`.

------------------------------------------------------------------------

## Development library via environment variable

The development library path is defined through an environment variable.

Add the following line to `~/.Renviron`:

``` text
MY_R_DEVLIB=~/path/to/dev/library
```

### Rationale

- Avoid hard-coded paths in R scripts
- Allow easy portability across machines
- Fail explicitly if misconfigured
- Separate policy from local filesystem details

If `MY_R_DEVLIB` is not defined, R startup fails with a clear error.

------------------------------------------------------------------------

## Local installation layout

On the local machine, the active configuration lives inside the user
home directory.

Expected layout:

``` text
~/.Rprofile
~/.Renviron
~/.R/
└─ toolbox/
   ├─ 00-config.R
   ├─ install_helpers.R
   ├─ upgrade_helpers.R
   └─ diagnostics.R
```

### Installation procedure

1.  Clone or download this repository.
2.  Copy the contents of the `/R/` directory into `~/.R/toolbox/`.

``` bash
mkdir -p ~/.R/toolbox
cp R/*.R ~/.R/toolbox/
```

------------------------------------------------------------------------

## Startup behaviour (`.Rprofile`)

The `~/.Rprofile` is deliberately minimal and only sources local
configuration files:

``` r
tb <- path.expand("~/.R/toolbox")

source(file.path(tb, "00-config.R"))
source(file.path(tb, "install_helpers.R"))
source(file.path(tb, "upgrade_helpers.R"))
source(file.path(tb, "diagnostics.R"))

message("R startup configured (system + dev)")
```

------------------------------------------------------------------------

## Role of each toolbox file

### `00-config.R` — library policy

- Reads `MY_R_DEVLIB`
- Ensures the development library exists
- Enforces `.libPaths(c(.Library, .myRlib))`

Defines policy only.

------------------------------------------------------------------------

### `install_helpers.R` — installation helpers

- `install_cran(pkgs)`  
  Installs CRAN packages into `.Library`.

- `install_my(path = ".")`  
  Installs a development package into the development library.

------------------------------------------------------------------------

### `upgrade_helpers.R` — R upgrade workflow

Before upgrading R:

``` r
save_cran_list()
```

After installing a new R version:

``` r
restore_cran_list()
```

This reinstalls all non-base packages cleanly into the new system
library.

------------------------------------------------------------------------

### `diagnostics.R` — validation utilities

Provides read-only diagnostics such as:

- `check_setup()`
- `list_sys_nonbase()`
- `list_dev_packages()`

------------------------------------------------------------------------

## RStudio workflow recommendations

- Use **Build & Reload** for development (`devtools::load_all()`).
- Use `install_my()` only when an installed copy is required.
- Use `install_cran()` for all CRAN packages.

------------------------------------------------------------------------

## Final note

This toolbox is intentionally **not an R package**. The `/R/` layout is
used for clarity and potential future evolution.

The emphasis is on **explicit configuration, reproducibility, and
control**.
