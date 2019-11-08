# Package helper
library(usethis) # helpful automation functions for common tasks in package development
library(pkgdown) # compile your R package to a website

pkgdown::build_site()

# generate description file with your info (need to set your info in advanve)
usethis::use_description()

# generate readme file, the contents control front page of pkgdown website
usethis::use_readme_md()

# create a vignette (.Rmd) document that gets compiled and displayed on pkdown website
usethis::use_vignette("get_started", title="Getting Started")

pkgdown::template_navbar() # generate yml for controlling navbar

render_folder_to_docs("slides")

use_logo("xtra/logo.png")
