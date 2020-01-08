#' Build vertical project
#'
#' Build the website associated with a vertical project. This is mostly a wrapper to `pkgdown::build_site()`, but extended to render .Rmd content from other folders.
#'
#' @param clean logical, when clean=TRUE (the default), the `docs` folder is cleaned (e.g., completely wiped) using `pkgdown::clean_site()`, otherwise when clean=FALSE `clean_site()` will not be run.
#' @param ... params, pass additional parameters to `pkgdown::build_site(...)`
#' @section Usage:
#' ```
#' build_vertical()
#' ```
#'
#' @export
build_vertical <- function(clean=TRUE,...) {

  if(clean == TRUE) pkgdown::clean_site()
  pkgdown::build_site(...)

  for (i in list.files(pattern = "\\.Rmd", recursive = TRUE)) {
    if(unlist(strsplit(i,split=.Platform$file.sep))[1] %in% c("experiments","vignettes") == FALSE){
      out.file <- rmarkdown::render(i, output_dir = paste0("docs/", dirname(i)), quiet=TRUE)
      if (!any(grepl(tools::file_path_sans_ext(i), readLines("_pkgdown.yml")))) {
        usethis::ui_info(paste(file.path(dirname(i),basename(out.file)),
                               " is not linked to in navbar. Please edit _pkgdown.yml"))
      }
    }
  }

  if (dir.exists("experiments")) {
    dir.create("docs/experiments")
    #file.copy("experiments", "docs", recursive = TRUE)
  }
}




