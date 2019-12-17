# vertical <a href='https:/crumplab.github.io/vertical'><img src='man/figures/logo.png' align="right" height="120.5" /></a>

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- badges: end -->

**Currently under development**

## Installation

The devtools library is required for installation:

``` r
#install.packages("devtools")
devtools::install_github("CrumpLab/vertical")
```

## Quick start

1. Install vertical (above), then restart RStudio
2. Create a new project
   - from the menu File > New Project...
   - or click the R cube in top-right hand corner, and select New Project...
3. Select the Vertical Project Template, give your vertical project a name (no spaces, only letters and numbers)
4. Create the project, then build the website by:

```
vertical::build_vertical()
```

Read the [getting started](https://crumplab.github.io/vertical/articles/vertical.html) tutorial to learn more about using `vertical`.

## What is vertical?

`vertical` is a workflow for creating, curating, and communicating research assets in psychological science in the form of a website and/or R package. It is effectively a wrapper for suggesting R Markdown templates for creating various psych research assets, and suggesting the R Package standard to curate the assets. `vertical` installs an RStudio project template with the `vertical` workflow structure, and compiles content in a `vertical` project to an R package and pkgdown website for sharing the assets.

### vertical workflow

<img src='man/figures/vertical-workflow.png'/>

### vertical project structure

<img src='man/figures/vertical-project.png'/>

### vertical website (via pkgdown)

<img src='man/figures/vertical-website.png'/>




