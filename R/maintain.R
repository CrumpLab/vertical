#' Update _pkgdown.yml for Rmds in vertical folders
#'
#' Write yml for the website navigation bar; run automatically by `build_vertical()`.
#'
#' @param vertical_folder character, name of a vertical folder, e.g., "vignettes"
#' @param docs_folder character, name of folder in docs, e.g., "articles"
#' @param yml_component character, name of the corresponding yml component, e.g., "articles"
#' @param tab_title character, the title of the component tab written to the website, e.g., "Supplementary"
#'
#' @return file, an updated _pkgdown.yml file
#'
#' @details `update_yml()` is a helper function for adding vertical content to the website navigation bar by upating `_pkgdown.yml`.
#'
#' Specifically, the titles of .Rmds in  `vertical_folder` and its subfolders are listed under the associated navbar component in `_pkgdown.yml`. If subfolders exist, then the name of the subfolder is used as a section header in the list. The sections and titles are shown in the dropdown navigation tab on the website.
#'
#' `_pkgdown.yml` can be further modified by hand to achieve various customizations to the website. See the [pkgdown documentation](https://pkgdown.r-lib.org/reference/build_site.html) for additional information.
#'
#' @export
update_yml <- function(vertical_folder,
                       docs_folder,
                       yml_component,
                       tab_title){

  if (dir.exists(vertical_folder)){
    # get rmds in folder
    top_rmds <- list.files(vertical_folder, pattern = "\\.Rmd$", full.names = TRUE)
    top_rmds_yml <- lapply(top_rmds,rmarkdown::yaml_front_matter)
    top_rmds_title <- unlist(sapply(top_rmds_yml,"[","title"))
    top_rmds_html <- list.files(vertical_folder, pattern = "\\.Rmd$")
    top_rmds_html <- gsub(".Rmd",".html",top_rmds_html)

    if (vertical_folder == "manuscript"){
      top_rmds_html <- list.files(vertical_folder, pattern = "\\.Rmd$")
      top_rmds_html <- gsub(".Rmd",".pdf",top_rmds_html)
    }

    # create temporary articles list
    new_articles <- list()
    new_articles <- list(text = tab_title,
                         menu  = list())

    # add main folder vignettes to list
    if(length(top_rmds) > 0) {
      for(i in 1:length(top_rmds_title)){
        new_articles$menu[[i]] <- list(text = top_rmds_title[i],
                                       href = paste(docs_folder,top_rmds_html[i],sep="/"))
      }
    }

    # add subfolder vignettes
    sub_folders <- list.dirs(vertical_folder, full.names=FALSE, recursive=FALSE)
    for(i in sub_folders){
      # get rmds in sub folder
      sub_rmds <- list.files(paste(vertical_folder,i,sep="/"),
                             pattern = "\\.Rmd$", full.names = TRUE)
      if(length(sub_rmds) > 0){
        # add folder name as text separator
        new_articles$menu[[length(new_articles$menu)+1]] <- list(text = i)

        sub_rmds_yml <- lapply(sub_rmds,rmarkdown::yaml_front_matter)
        sub_rmds_title <- unlist(sapply(sub_rmds_yml,"[","title"))
        sub_rmds_html <- list.files(paste(vertical_folder,i,sep="/"), pattern = "\\.Rmd$")
        sub_rmds_html <- gsub(".Rmd",".html",sub_rmds_html)

        # add sub folder vignettes to list
        if(length(sub_rmds) > 0) {
          for(j in 1:length(sub_rmds_title)){
            new_articles$menu[[length(new_articles$menu)+1]] <- list(text = sub_rmds_title[j],
                                                                     href = paste(docs_folder,i,sub_rmds_html[j],sep="/"))
          }
        }
      }
    } #end loop

    if( file.exists("_pkgdown.yml") ){
      temp_yml <- yaml::read_yaml("_pkgdown.yml")
      temp_yml$navbar$components[[yml_component]] <- new_articles
      yaml::write_yaml(temp_yml,"_pkgdown.yml")
    }
  }
}
