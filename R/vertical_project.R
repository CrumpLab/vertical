#' Initialize a **vertical** project
#'
#' This function is called when a **vertical** R project is created.
#'
#' @param path Where to create the project. This must be a valid R package name.
#' @param ...  Not used.
#'
#' @export
vertical_project <- function(path, ...) {

  dots <- list(...)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # This is a package
  usethis::create_package(path, open = FALSE)
  setwd(paste0(getwd(), "/", path)) # [TODO] improve this hack

  # Git?
  if (dots$init_git) {
    git2r::init(usethis::proj_get())
    usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))
  }

  # pkgdown template
  vertical_pkgdown <- system.file("vertical/_pkgdown.yml", package = "vertical")
  file.copy(vertical_pkgdown, "_pkgdown.yml")

  usethis::use_data_raw(open = FALSE)
  if (dots$init_ms) init_papaja()
  if (dots$init_som) init_supplemental()
  if (dots$init_slides) init_slides()
  if (dots$init_poster) init_poster()
  if (dots$init_exp) init_jspsych()
}

#' Initialize manuscript
#'
#' Initialize Rmarkdown APA manuscript in the appropriate location of a vertical project
#'
#' @export
init_papaja <- function() {
  usethis::use_directory("manuscript", ignore = TRUE)
  rmarkdown::draft(
    file = "manuscript/manuscript.Rmd",
    template = "apa6",
    package = "papaja",
    edit = FALSE,
    create_dir = FALSE
  )
}

#' Initialize supplemental materials
#'
#' Initialize Rmarkdown SOM in the appropriate location of a vertical project
#'
#' @export
init_supplemental <- function() {
  usethis::use_article(
    "Supplemental_1",
    title = "Supplementary analyses"
  )
}

#' Initialize slides
#'
#' Initialize Rmarkdown slides in the appropriate location of a vertical project
#'
#' @export
init_slides <- function() {
  usethis::use_directory("slides", ignore = TRUE)
  rmarkdown::draft(
    file = "slides/slides.Rmd",
    template = "slidy",
    package = "vertical",
    edit = FALSE,
    create_dir = FALSE
  )
}

#' Initialize posters
#'
#' Initialize Rmarkdown posters in the appropriate location of a vertical project
#'
#' @export
init_poster <- function() {
  usethis::use_directory("posters", ignore = TRUE)
  rmarkdown::draft(
    file = "posters/poster.Rmd",
    template = "posterdown_html",
    package = "posterdown",
    edit = FALSE,
    create_dir = FALSE
  )
}

#' Initialize jsPsych experiment
#'
#' Initialize a jsPsych experiment in the appropriate location of a vertical project
#'
#' @export
init_jspsych <- function() {
  usethis::use_directory("experiments", ignore = TRUE)
  usethis::use_directory("experiments/experiment-1")
  # Get latest jsPsych version download link
  ver <- basename(httr::GET("https://github.com/jspsych/jsPsych/releases/latest")$url)
  loc_from <- paste0(
    "https://github.com/jspsych/jsPsych/releases/download/", ver,
    "/jspsych-", sub("v", "", ver), ".zip"
  )
  # Download, unzip, and remove .zip
  loc_to <- file.path("experiments", basename(loc_from))
  utils::download.file(url = loc_from, loc_to)
  utils::unzip(loc_to, exdir = sub(".zip", "", loc_to))
  unlink(loc_to)
  # Suggest deleting unnecessary large folder
  message(paste0("Consider removing ", sub(".zip", "", loc_to), "/examples"))
  vertical_jspsych <- system.file("vertical/experiment.html", package = "vertical")
  file.copy(vertical_jspsych, "experiments/experiment-1/index.html")
}

#' Update _pkgdown.yml for Rmds in Folders
#'
#' @param folder character, name of a vertical folder, e.g., "vignettes"
#' @param yml_component character, name of the corresponding yml component, e.g., "articles"
#' @param tab_title character, the title of the component tab written to the website, e.g., "Supplementary"
#'
#' @return file, an updated _pkgdown.yml file
#'
#' @description This function scrapes a folder and all sub-folders for R markdown documents, and then updates the a designated yml component in _pkgdown.yml with a new list of items. The list of items in shown in the component's tab on the website, and the title of the tab is set to `tab_title`. In the tab, the titles of each .rmd in the main folder are added; then, for each sub-folder the sub-folder name is added (as a text seperator in the tab), followed by the titles for each .rmd in the sub-folder. This function is run automatically by `build_vertical()`.
#'
#' @export
#'

update_yml <- function(folder,yml_component,tab_title){

  if (dir.exists(folder)){
    # get rmds in folder
    top_rmds <- list.files(folder, pattern = "\\.Rmd$", full.names = TRUE)
    top_rmds_yml <- lapply(top_rmds,rmarkdown::yaml_front_matter)
    top_rmds_title <- unlist(sapply(top_rmds_yml,"[","title"))
    top_rmds_html <- list.files(folder, pattern = "\\.Rmd$")
    top_rmds_html <- gsub(".Rmd",".html",top_rmds_html)

    # create temporary articles list
    new_articles <- list()
    new_articles <- list(text = tab_title,
                         menu  = list())

    # add main folder vignettes to list
    if(length(top_rmds) > 0) {
      for(i in 1:length(top_rmds_title)){
        new_articles$menu[[i]] <- list(text = top_rmds_title[i],
                                       href = paste(folder,top_rmds_html[i],sep="/"))
      }
    }

    # add subfolder vignettes
    sub_folders <- list.dirs(folder, full.names=FALSE, recursive=FALSE)
    for(i in sub_folders){
      # get rmds in sub folder
      sub_rmds <- list.files(paste(folder,i,sep="/"),
                             pattern = "\\.Rmd$", full.names = TRUE)
      if(length(sub_rmds) > 0){
        # add folder name as text separator
        new_articles$menu[[length(new_articles$menu)+1]] <- list(text = i)

        sub_rmds_yml <- lapply(sub_rmds,rmarkdown::yaml_front_matter)
        sub_rmds_title <- unlist(sapply(sub_rmds_yml,"[","title"))
        sub_rmds_html <- list.files(paste(folder,i,sep="/"), pattern = "\\.Rmd$")
        sub_rmds_html <- gsub(".Rmd",".html",sub_rmds_html)

        # add sub folder vignettes to list
        if(length(sub_rmds) > 0) {
          for(j in 1:length(sub_rmds_title)){
            new_articles$menu[[length(new_articles$menu)+1]] <- list(text = sub_rmds_title[j],
                                                                     href = paste(folder,i,sub_rmds_html[j],sep="/"))
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

#' Build vertical project
#'
#' Build the website associated with a vertical project
#'
#' @param clean logical, when clean=TRUE (the default), the `docs` folder is cleaned (e.g., completely wiped) using `pkgdown::clean_site()`, otherwise when clean=FALSE `clean_site()` will not be run.
#' @param update_yml logical, update_yml=TRUE is the default, updates yml components in `_pkgdown.yml` to list all .Rmds in folders and subfolders of vertical components (manuscript, posters, slides, vignettes) in associated navigation bar tabs on the website.
#' @param ... params, pass additional parameters to `pkgdown::build_site(...)`
#'
#' @export
build_vertical <- function(clean=TRUE,update_yml=TRUE,...) {
  if(update_yml == TRUE) {
    update_yml("vignettes","articles","Supplementary")
    update_yml("manuscript","manuscript","PDF")
    update_yml("posters","posters","Poster")
    update_yml("slides","slides","Slides")
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
