#' Initialize a **vertical** project as RStudio project template
#'
#' This function is called when a **vertical** R project is created.
#'
#' @param path Where to create the project. This must be a valid R package name.
#' @param ...  Not used.
#'
#' @export
vertical_project <- function(path, ...) {

  dots <- list(...)
  #dir.create(path, recursive = TRUE, showWarnings = FALSE)
  p_name <- path
  path <- file.path(getwd(), path)

  # This is a package
  usethis::create_package(path, open = FALSE)
  usethis::proj_set(path)
  #setwd(paste0(getwd(), "/", path)) # [TODO] improve this hack
  setwd(path)

  # Git?
  if (dots$init_git) {
    git2r::init(usethis::proj_get())
    usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))
  }

  # pkgdown template
  #vertical_pkgdown <- system.file("vertical/_pkgdown.yml", package = "vertical")
  #file.copy(vertical_pkgdown, "_pkgdown.yml")
  usethis::use_template(template = "_pkgdown.yml",
                        package = "vertical")

  usethis::use_data_raw(open = FALSE)
  if (dots$init_ms) init_papaja()
  if (dots$init_som) init_supplemental(prjct_name = p_name)
  if (dots$init_slides) init_slides()
  if (dots$init_poster) init_poster()
  if (dots$init_exp) init_jspsych()
}

#' Initialize a vertical project from command line
#'
#' @param project_name character, name of new vertical project, default is project_name = NULL, for initializing inside an existing empty R studio project
#' @param project_path character, path where new project should be created, default is project_path = NULL for initializing inside an existing empty R studio project
#' @param init_git logical, enables git, init_git=TRUE by default
#' @param init_ms logical, enables manuscript with papaja, init_ms=TRUE by default
#' @param init_som logical, enables supplementary with vignettes, init_som=TRUE by default
#' @param init_slides logical, enables slides with slidy, init_slides=TRUE by default
#' @param init_poster logical, enables posters with posterdown, init_poster=TRUE by default
#' @param init_exp logical, enables experiments with jspsych, init_exp=TRUE by default
#'
#' @return files, a vertical project template inside an existing or new R Studio project
#' @description Initiliazing a vertical project inside an existing project: The name of the existing project (e.g., the project folder name) must be a valid R package name (numbers, letters, and periods, but no periods at the end, and no spaces, dashes, or underscores). It is not necessary to supply project_name or project_path, they default to the current existing project.
#'
#' Initializing a vertical project as a new project: provide a name and path, and a new vertical project will be set up in an R studio project.
#'
#' @export
#' @examples
#' \dontrun{
#' init_vertical_project()
#' }
#'
#'
init_vertical_project <- function(project_name = NULL,
                                  project_path = NULL,
                                  init_git = TRUE,
                                  init_ms = TRUE,
                                  init_som = TRUE,
                                  init_slides = TRUE,
                                  init_poster = TRUE,
                                  init_exp = TRUE) {

  if(is.null(project_path)==FALSE) {
    path <- file.path(project_path,project_name)
  } else{
    path <- getwd()
  }

  # This is a package
  usethis::create_package(path, open = FALSE)
  usethis::proj_set(path)
  # setwd(paste0(getwd(), "/", path)) # [TODO] improve this hack

  # Git?
  if (init_git) {
    git2r::init(usethis::proj_get())
    usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))
  }

  # pkgdown template
  #vertical_pkgdown <- system.file("vertical/_pkgdown.yml", package = "vertical")
  #file.copy(vertical_pkgdown, "_pkgdown.yml")
  usethis::use_template(template = "_pkgdown.yml",
                        package = "vertical")

  usethis::use_data_raw(open = FALSE)
  if(is.null(project_path)==FALSE) setwd(path)
  if (init_ms) init_papaja()
  if (init_som) init_supplemental(prjct_name = project_name)
  if (init_slides) init_slides()
  if (init_poster) init_poster()
  if (init_exp) init_jspsych()
  if(is.null(project_path)==FALSE) usethis::proj_activate(path)
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
init_supplemental <- function(prjct_name=NULL) {

  if(is.null(prjct_name) == FALSE){
    usethis::use_directory("vignettes")
    usethis::use_template(template = "article.Rmd",
                          save_as = "vignettes/Supplementary_1.Rmd",
                          data = list(vignette_title="Supplementary analyses",
                                      Package = prjct_name),
                          package = "usethis")
  } else{
    usethis::use_article(
      "Supplemental_1",
      title = "Supplementary analyses"
    )
  }
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
#' @param vertical_folder character, name of a vertical folder, e.g., "vignettes"
#' @param docs_folder character, name of folder in docs, e.g., "articles"
#' @param yml_component character, name of the corresponding yml component, e.g., "articles"
#' @param tab_title character, the title of the component tab written to the website, e.g., "Supplementary"
#'
#' @return file, an updated _pkgdown.yml file
#'
#' @description This function scrapes a folder and all sub-folders for R markdown documents, and then updates the a designated yml component in _pkgdown.yml with a new list of items. The list of items in shown in the component's tab on the website, and the title of the tab is set to `tab_title`. In the tab, the titles of each .rmd in the main folder are added; then, for each sub-folder the sub-folder name is added (as a text seperator in the tab), followed by the titles for each .rmd in the sub-folder. This function is run automatically by `build_vertical()`.
#'
#' @export
#'

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
    update_yml("vignettes","articles","articles","Supplementary")
    update_yml("manuscript","manuscript","manuscript","PDF")
    update_yml("posters","posters","posters","Poster")
    update_yml("slides","slides","slides","Slides")
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



#' Add R dataframe and document
#'
#' document_data() is a helper function for quickly adding an existing dataframe to an R package. For example, if mydf was an existing data frame, document_data(mydf) would create the data folder (if it doesn't exist), add mydf.rda to the data folder, add mydf.R to the R folder with a roxygen skeleton for documenting the data, and open mydf.R for editing.
#'
#' @param ... the name of a single dataframe in the global environment
#'
#' @return files, adds dataframe as .rda to data folder, adds .R to R for documentation
#'
#' @description A wrapper to usethis::use_data(), usethis::use_r(), and sinew::makeOxygen()
#'
#' @export
#'
#' @examples
#' \dontrun{
#' document_data(mydf)
#' }
document_data <- function(...){
  usethis::use_data(...)
  data_name <- deparse(substitute(...))
  usethis::use_r(data_name)
  switch(menu(c("Yes, add new Roxygen skeleton", "No, show me the file"), title="Overwrite existing .R file?"),
         cat(sinew::makeOxygen(...),file="R/mydf.R",sep="\n"),2
  )
}
