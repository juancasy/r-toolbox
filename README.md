Toolbox for package management on macOS
================

## Foreword

This document describes a **personal** toolbox for managing R packages
on macOS. It is my personal philosophy and setup, shared here for
reference and possible inspiration. It is **not** intended as a
general-purpose package management solution.

## Overview

Since I develop R packages frequently and use R over many years, it is
important for me to have a clear and reproducible setup for managing
packages, where personal development and CRAN packages are clearly
separated.

1.  **System library** (`.Library`)
    - R base and recommended packages
    - CRAN packages
2.  **Development library** (custom path)
    - User-developed packages under active development

The design goals are:

- Minimal complexity at R/RStudio startup
- Full control over where packages are installed
- No implicit behaviour or silent fallbacks
- A clean and reproducible workflow for **R upgrades**
- No dependency on external repositories at startup

This setup assumes that the **system library is writable** (standard
macOS Framework installation of R).

------------------------------------------------------------------------

## Quick start

This section summarises the minimal steps required to activate the
toolbox on a new macOS machine.

### 1. Define the development library

Add the following line to your `~/.Renviron` file:

``` text
MY_R_DEVLIB=~/Dropbox/Boulot/dev/r/myRlib
```

Restart RStudio after editing `.Renviron`.

------------------------------------------------------------------------

### 2. Copy the toolbox files

Clone or download this repository, then copy the helper files to your
local R configuration directory:

``` bash
mkdir -p ~/.R/toolbox
cp R/*.R ~/.R/toolbox/
```

------------------------------------------------------------------------

### 3. Configure startup

Add the following content **verbatim** to your `~/.Rprofile`:

``` r
tb <- path.expand("~/.R/toolbox")

source(file.path(tb, "00-config.R"))
source(file.path(tb, "install_helpers.R"))
source(file.path(tb, "upgrade_helpers.R"))
source(file.path(tb, "diagnostics.R"))

message("✅ R startup configured (system + dev)")
```

Restart RStudio.

------------------------------------------------------------------------

### 4. Verify the setup

Run in R:

``` r
check_setup()
```

You should see:

- exactly two entries in `.libPaths()` (system + dev),
- write access to both libraries,
- no errors.

At this point the toolbox is fully operational.

------------------------------------------------------------------------

## Repository structure

This repository **includes the actual `.R` helper files**, stored under
a top-level `/R/` directory (similarly to an R package layout, although
this is *not* a package).

    toolbox/
    ├─ README.Rmd
    └─ R/
       ├─ 00-config.R
       ├─ install_helpers.R
       ├─ upgrade_helpers.R
       └─ diagnostics.R

The repository serves as **documentation and a reference
implementation**. The files under `/R/` must be **copied verbatim** to
the local R installation, as described below.

------------------------------------------------------------------------

## Library policy

At startup, the following library order is enforced:

``` r
.libPaths()
```

Expected result:

``` text
[1] /Library/Frameworks/R.framework/Versions/<R-version>/Resources/library
[2] <MY_R_DEVLIB>
```

Meaning:

- **System library** (`.Library`)
  - Base / recommended packages
  - All CRAN packages
- **Development library** (`MY_R_DEVLIB`)
  - User-developed packages only

No user library (`R_LIBS_USER`) is used in `.libPaths()`.

------------------------------------------------------------------------

## Development library via environment variable

The development library path is defined through an **environment
variable**. Add the following line to your `~/.Renviron` file:

``` text
MY_R_DEVLIB=~/Dropbox/Boulot/dev/r/myRlib
```

### Why use an environment variable?

- Avoid hard-coded paths in R scripts
- Easy portability across machines
- Clear failure if misconfigured
- Separation between *policy* and *local paths*

If `MY_R_DEVLIB` is not defined, R startup fails explicitly with a clear
error.

------------------------------------------------------------------------

## Local installation layout

On the local machine, the active configuration lives **inside the user
home**, not inside the GitHub repository.

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

Example:

``` bash
mkdir -p ~/.R/toolbox
cp R/*.R ~/.R/toolbox/
```

------------------------------------------------------------------------

## Startup behaviour (`.Rprofile`)

The `~/.Rprofile` is deliberately minimal and only sources local files.
Add the following content **verbatim**:

``` r
tb <- path.expand("~/.R/toolbox")

source(file.path(tb, "00-config.R"))
source(file.path(tb, "install_helpers.R"))
source(file.path(tb, "upgrade_helpers.R"))
source(file.path(tb, "diagnostics.R"))

message("✅ R startup configured (system + dev)")
```

No logic, no installation, no side effects beyond configuration.

------------------------------------------------------------------------

## Role of each toolbox file

### `00-config.R` — library policy

Responsibilities:

- Read `MY_R_DEVLIB`
- Ensure the development library exists
- Enforce `.libPaths(c(.Library, .myRlib))`

This file defines **policy**, not actions.

------------------------------------------------------------------------

### `install_helpers.R` — installation helpers

Provides explicit helpers:

- `install_cran(pkgs)` → installs CRAN packages **into `.Library`**

- `install_my(path = ".")` → installs the current development package
  **into the dev library**

RStudio’s *Install and Restart* button is deliberately avoided.

------------------------------------------------------------------------

### `upgrade_helpers.R` — R upgrade workflow

Defines a reproducible workflow for R upgrades.

Before upgrading R:

``` r
save_cran_list()
```

This saves the list of non-base / non-recommended packages currently
installed in `.Library`.

After installing a new R version:

``` r
restore_cran_list()
```

All packages are reinstalled cleanly into the new system library.

This avoids copying binaries across R versions.

------------------------------------------------------------------------

### `diagnostics.R` — validation and inspection

Provides utilities such as:

- `check_setup()` Prints:

  - `.libPaths()`
  - write permissions
  - test package locations

- `list_sys_nonbase()` Lists CRAN packages installed in `.Library`.

- `list_dev_packages()` Lists packages installed in the development
  library.

These functions are **read-only** and safe.

------------------------------------------------------------------------

## RStudio workflow recommendations

### Package development

- Use **Build & Reload**
  - loads the package via `devtools::load_all()`
  - does *not* install anything
- Use `install_my()` when an installed copy is needed.

### CRAN packages

Always use:

``` r
install_cran("pkgname")
```

This guarantees the package ends up in `.Library`.

------------------------------------------------------------------------

## R upgrades (summary)

Before upgrading R:

``` r
save_cran_list()
```

Install new R version (macOS Framework installer).

Restart RStudio.

Restore packages:

``` r
restore_cran_list()
```

This yields a clean, version-consistent system library.

------------------------------------------------------------------------

## Why this setup works well

- Explicit over implicit
- No magic paths
- No dependency on GitHub at startup
- Reproducible upgrades
- Clear separation of concerns
- Easy to debug

This configuration is particularly well suited for:

- long-term scientific workflows
- multiple R versions over time
- mixed CRAN + development usage
- environments where stability matters more than convenience

------------------------------------------------------------------------

## Final note

This toolbox is intentionally **not an R package**.

The use of a `/R/` directory mirrors a package layout only for clarity
and future extensibility. If, at some point, interactive help or
namespace control becomes desirable, these helpers could be migrated
into a small personal package without changing the underlying
philosophy.

For now, simplicity and explicitness take precedence.
