#' Build vertical project
#'
#' Build the website associated with a vertical project. This is mostly a wrapper to `pkgdown::build_site()`, but extended to render content from vertical folders.
#'
#' @param clean logical, when clean=TRUE (the default), the `docs` folder is cleaned (e.g., completely wiped) using `pkgdown::clean_site()`, otherwise when clean=FALSE `clean_site()` will not be run.
#' @param update_yml logical, update_yml=FALSE is the default so existing yml **is not overwritten**, updates yml components in `_pkgdown.yml` to list all .Rmds in folders and subfolders of vertical components (manuscript, posters, slides, vignettes) in associated navigation bar tabs on the website. Set to TRUE to overwrite.
#' @param ... params, pass additional parameters to `pkgdown::build_site(...)`
#' @section Usage:
#' ```
#' build_vertical()
#' ```
#'
#' @export
build_vertical <- function(clean=TRUE,update_yml=FALSE,...) {
  if(update_yml == TRUE) {
    update_yml("vignettes","articles","articles","Supplementary")
    update_yml("manuscript","manuscript","manuscript","PDF")
    update_yml("posters","posters","posters","Poster")
    update_yml("slides","slides","slides","Slides")
    update_yml("experiments","experiments","experiments","Experiments")
  }
  if(clean == TRUE) pkgdown::clean_site()
  pkgdown::build_site(...)

  if (dir.exists("posters")) {
    file_names <- list.files("posters", pattern = "\\.Rmd$")
    for(i in file_names){
      rmarkdown::render(paste("posters",i,sep="/"),
                        output_dir = "docs/posters/")
    }
  }

  if (dir.exists("slides")) {
    file_names <- list.files("slides", pattern = "\\.Rmd$")
    for(i in file_names){
      rmarkdown::render(paste("slides",i,sep="/"),
                        output_dir = "docs/slides/")
    }
  }

  if (dir.exists("manuscript")) {
    # Works, but throws error if file not created first
    file.create("manuscript/r-references.bib")
    file_names <- list.files("manuscript", pattern = "\\.Rmd$")
    for(i in file_names){
      rmarkdown::render(paste("manuscript",i,sep="/"),
                        output_dir = "docs/manuscript/")
    }
  }
  if (dir.exists("experiments")) {
    dir.create("docs/experiments")
    file.copy("experiments", "docs", recursive = TRUE)
  }
}




