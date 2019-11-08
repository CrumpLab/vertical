# for more help with vertical go to https://crumplab.github.io/vertical/

# Vertical helper
library(usethis) # helpful automation functions for common tasks in package development
library(pkgdown) # helpful automation functions for common tasks in package development
library(vertical) # vertical helper functions

# compile the website using pkgdown
pkgdown::build_site()

# clean the site (deletes everythng in docs folder)
pkgdown::clean_site()

# render slides to docs (for display on website)
vertical::render_folder_to_docs("slides")

# generate description file with your info (need to set your info in advance)
# see https://usethis.r-lib.org/reference/use_description.html
usethis::use_description()

# create a vignette (.Rmd) document that gets compiled and displayed on website under supplementary
usethis::use_vignette("Supplemental_2", title="Supplemental 2")



