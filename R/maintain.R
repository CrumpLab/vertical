#' Suggest yml for _pkgdown.yml
#'
#' Run `vertical::suggest_yml` to generate a suggestions for populating `_pkgdown.yml`. The suggested yml is written to the console. Copy this to `_pkgdown.yml` and modify as necessary.
#'
#' @return yml copied to console
#'
#' @details `_pkgdown.yml` can be further modified by hand to achieve various customizations to the website. See the [pkgdown documentation](https://pkgdown.r-lib.org/reference/build_site.html) for additional information.
#'
#' @export
#'
suggest_yml <- function(){
  temp_yml <- yaml::read_yaml("_pkgdown.yml")
  exclude_folders <- c("experiments","data","data-raw","docs","R","man","inst")

  # write structure and components
  for (i in list.files(pattern = "\\.Rmd", recursive = TRUE)) {
    assets <- unlist(strsplit(i,split=.Platform$file.sep))
    if(assets[1] %in% exclude_folders == FALSE ){
      if (assets[1] == "vignettes") assets[1] <- "articles"
      if(assets[1] %in% temp_yml$navbar$structure$left == FALSE) temp_yml$navbar$structure$left <- c(temp_yml$navbar$structure$left,assets[1])
      temp_yml$navbar$components[[assets[1]]] <- list(text = assets[1],menu = list())
    }
  }

  # write titles and hrefs
  for (i in list.files(pattern = "\\.Rmd", recursive = TRUE)) {
    assets <- unlist(strsplit(i,split=.Platform$file.sep))
    j <- assets
    if(assets[1] %in% exclude_folders == FALSE ){
      if (assets[1] == "vignettes") assets[1] <- "articles"; j[1] <- "articles"
      temp_yml$navbar$components[[assets[1]]]$menu <- c(
        temp_yml$navbar$components[[assets[1]]]$menu,
        list(list(text = rmarkdown::yaml_front_matter(i)$title,
                  href=gsub(".Rmd",".html",paste(j,collapse="/"))))
      )
      # [todo] handle file types? only html so far
    }
  }

  # print suggested yml to console
  usethis::ui_info("Copy to _pkgdown.yml then modify as needed")
  usethis::ui_info("tip: change .html to .pdf in hrefs for papaja manuscripts, or other .pdf assets")
  filename <- tempfile()
  con <- file(filename, "w")
  yaml::write_yaml(temp_yml, con)
  close(con)
  writeLines(readLines(filename))
  unlink(filename)
}


