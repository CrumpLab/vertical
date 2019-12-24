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
  temp_yml$navbar$components$articles <- NULL

  for (i in list.files(pattern = "\\.Rmd", recursive = TRUE)) {
    #j <- gsub("vignettes","articles",i)
    assets <- gtools::split_path(i,FALSE)
    j <- assets
    if(assets[1] %in% c("experiments","data","data-raw","docs","R","man","inst") == FALSE ){

      # handle vignettes exception
      if (assets[1] == "vignettes") {
        assets[1] <- "articles"
        j[1] <- "articles"
      }

      # write structure to left
      if(assets[1] %in% temp_yml$navbar$structure$left == FALSE) {
        temp_yml$navbar$structure$left <- c(temp_yml$navbar$structure$left,assets[1])
      }

      # write top level component tab text and menu
      if( "menu" %in% names(temp_yml$navbar$components[[assets[1]]]) == FALSE) {
        temp_yml$navbar$components[[assets[1]]] <- list(text = assets[1],
                                                        menu = list())
      }

      # write titles and hrefs
      temp_yml$navbar$components[[assets[1]]]$menu <- rlist::list.append(
        temp_yml$navbar$components[[assets[1]]]$menu,
        list(text = rmarkdown::yaml_front_matter(i)$title,
             href=gsub(".Rmd",".html",paste(j,collapse="/")))
      )
      # [todo] handle file types? only html so far
    }
  }

  usethis::ui_info("Copy to _pkgdown.yml then modify as needed")
  ymlthis::as_yml(temp_yml)
}
