#' Initialize **vertical** project from RStudio project template
#'
#' **NOT for use in the console**
#'
#' `vertical_project()` is triggered by loading a new vertical project template from RStudio, and is a wrapper function to create a vertical project structure in the new project folder. The inputs  to this function are selections from the new project template window. Checkbox option for the template are defined in `inst/rstudio/templates/project/vertical_project.dcf`.
#'
#'
#' @param path Where to create the project. This must be a valid R package name.
#' @param ...  Not used.
vertical_project <- function(path, ...) {

  dots <- list(...)
  #dir.create(path, recursive = TRUE, showWarnings = FALSE)
  p_name <- path
  path <- file.path(getwd(), path)

  # This is a package
  usethis::create_package(path, open = FALSE)
  usethis::proj_set(path)
  setwd(path) # [TODO] improve this hack


  # Git?
  if (dots$init_git) {
    git2r::init(usethis::proj_get())
    usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))
  }

  # pkgdown template
  usethis::use_template(template = "_pkgdown.yml",
                        package = "vertical")

  # additional content modules
  usethis::use_data_raw(open = FALSE)
  if (dots$init_ms) init_papaja()
  if (dots$init_som) init_supplemental(prjct_name = p_name)
  if (dots$init_slides) init_slides()
  if (dots$init_poster) init_poster()
  if (dots$init_exp) init_jspsych()
}

#' Initialize vertical project from command line
#'
#' Use `vertical::init_vertical_project()` to initialize a vertical project from the command line.
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
#' @return **files**, a vertical project template inside an existing or new R Studio project
#'
#' @details
#'
#' **Interactive: Get asked what you want to do**
#' ```
#' vertical::init_vertical_project()
#' ```
#' This opens a dialogue in the console. You choose whether to make a brand new RStudio project, or to initialize vertical in an existing project that you are already working. Follow the prompts and choose which vertical modules to load.
#'
#' **Scripted: Do what you want to do**
#'
#' If any input parameters are specified, then initialization is done directly without a dialogue.
#'
#' **Initializing a vertical project inside an existing project**:
#' It is not necessary to name the project, because a named project should already be open. At least one of the modules should be specified. Default NULL values are set to FALSE, and those modules are not loaded.
#' ```
#' init_vertical_project(init_git=TRUE,...)
#' ```
#' The name of the existing project (e.g., the project folder name) must be a valid R package name (numbers, letters, and periods, but no periods at the end, and no spaces, dashes, or underscores). It is not necessary to supply project_name or project_path, they default to the current existing project.
#'
#'
#' **Initializing a vertical project as a new project**:
#' Provide a name and path to set up a new vertical project as an R studio project, and specify which modules should be loaded by setting their parameters to TRUE.
#' ```
#' init_vertical_project(project_name = "yourname",
#'                       project_path = "~/Desktop/",
#'                       init_git = TRUE,
#'                       ...)
#' ```
#' For example, the above creates the folder `~Desktop/yourname/`, creates the vertical project template in that folder, and opens a new RStudio session with the new project loaded. Make sure `yourname` is valid R package name.
#'
#' @export
init_vertical_project <- function(project_name = NULL,
                                  project_path = NULL,
                                  init_git = NULL,
                                  init_ms = NULL,
                                  init_som = NULL,
                                  init_slides = NULL,
                                  init_poster = NULL,
                                  init_exp = NULL){

  use_prompt <- is.null(project_name) & is.null(project_path) & is.null(init_git) &
    is.null(init_ms) & is.null(init_som) & is.null(init_slides) & is.null(init_poster) &
    is.null(init_exp) & interactive()

  # for interactive ui, ask user what they want

  if(use_prompt){

    # Ask user for init type

    cat("Vertical initialization options:\n\n")
    cat("  [1] Initialize in new project in new directory\n")
    cat("  [2] Initialize in the existing open project\n")
    ans <- readline("Selection: ")
    ans <- suppressWarnings(as.numeric(ans))
    cat("\n")

    # make new project
    if(ans == 1) {
      if(usethis::ui_yeah("Your current R session will close, with an option to save it. Continue?")){
        usethis::ui_info("Opening R New Project viewer. Select New directory > Vertical Research Project... ")
        rstudioapi::executeCommand('newProject', quiet = FALSE)
      } else{
        usethis::ui_oops("No problem, maybe another time")
      }
    }

    # make in existing
    if(ans == 2) {
      if(usethis::ui_yeah("Initialize all modules? Easiest option...you can delete ones you don't need later")){
        init_git <- TRUE
        init_ms  <- TRUE
        init_som <- TRUE
        init_slides <- TRUE
        init_poster <- TRUE
        init_exp <- TRUE
      } else {
        init_git <- usethis::ui_yeah("use git? recommended")
        init_ms  <- usethis::ui_yeah("use papaja manuscript?")
        init_som <- usethis::ui_yeah("use supplemental materials?")
        init_slides <- usethis::ui_yeah("use slides?")
        init_poster <- usethis::ui_yeah("use poster?")
        init_exp <- usethis::ui_yeah("use jspsych and jspsychr for experiments?")
      }
    }
  }

  # for scripting option, do what user says

  use_script <- is.null(project_name) & is.null(project_path) & is.null(init_git) &
    is.null(init_ms) & is.null(init_som) & is.null(init_slides) & is.null(init_poster) &
    is.null(init_exp) & interactive()

  if(!use_script){

    # set NULLs to FALSE
    if(is.null(init_git)) init_git <- FALSE
    if(is.null(init_ms)) init_ms <- FALSE
    if(is.null(init_som)) init_som <- FALSE
    if(is.null(init_slides)) init_slides <- FALSE
    if(is.null(init_poster)) init_poster <- FALSE
    if(is.null(init_exp)) init_exp <- FALSE

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

}

#' Initialize manuscript
#'
#' Initialize `papaja` R Markdown APA manuscript in the `manuscript` folder.
#'
#' Run this function to add a `papaja` manuscript component to a vertical project at a later time (assuming it wasn't created by `vertical_project()` or `init_vertical_project()` during initialization.)
#'
#' See the [papaja documentation](https://crsh.github.io/papaja_man/) for more information.
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
#' Initialize R Markdown SOM in the `vignettes` of a vertical project.
#'
#' A wrapper to `usethis` for creating a `vignettes` folder, and adding an example .Rmd. This function is used during vertical project creation. Once a vertical project is established, we suggest a `usethis` approach to adding articles to vignettes. The `usethis` approach creates a new .Rmd in `vignettes`, you define the name and title, and the new file is opened for editing.
#' ```
#' usethis::use_article(name, title = name)
#' usethis::use_article("Supplementary_2", title = "Blah blah blah")
#' ```
#' See [usethis documentation](https://usethis.r-lib.org/reference/use_vignette.html) for more information.
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
#' Initialize slidy R Markdown template in slides folder of a vertical project
#'
#' Run on initialization, and can be run from the console to include a slides folder and slidy template at a later time. See the [slidy documentation](https://bookdown.org/yihui/rmarkdown/slidy-presentation.html) for additional information. There are other R markdown slide templates not suggested by vertical, but that are very good alternatives (e.g., `xaringan`). Simply add your template of choice to the slides folder.
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
#' Initialize R Markdown `posterdown` template in `posters` folder of a vertical project
#'
#' Run on initialization, and can be run from the console to include a posters folder and poster template at a later time. See the [posterdown documentation](https://github.com/brentthorne/posterdown) for more information. Note that `vertical` loads one of the three possible `posterdown` templates.
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
#' Initialize a jsPsych experiment in the `experiments` folder of a vertical project
#'
#' This function does the following:
#' 1. creates the `experiments` folder
#' 2. Downloads the most recent `jspsych`` library from <https://github.com/jspsych/jsPsych/releases>
#' 3. Adds a minimal `jspsych`` example experiment to `experiments/experiment-1/`
#'
#' See the [jspsych documentation](https://www.jspsych.org) for more information about using jspsych to build behavioral experiments for the web.
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
  usethis::use_template(template = "experiment.html",
                        save_as = "experiments/experiment-1/experiment.html",
                        package = "vertical")
}

#' Initialize jspsychr experiment
#'
#' Initialize a jspsychr template in the `experiments` folder of a vertical project
#'
#' This function does the following:
#' 1. creates the `experiments` folder
#' 2. Adds a `jspsychr` template (Experiment_1), which is an example of using R Studio and R Markdown to author a `jspsych` experiment
#'
#' See the [jspsych documentation](https://www.jspsych.org) for more information about using jspsych to build behavioral experiments for the web.
#'
#' See the [jspsychr documentation](https://crumplab.github.io/jspsychr/) for more information about using R Markdown to write `jspsych` experiments.
#'
#' @export
init_jspsychr <- function(){
  usethis::use_directory("experiments", ignore = TRUE)
  # add jspsychr template example
  rmarkdown::draft(
    file = "experiments/Experiment_1.Rmd",
    template = "jspsychr",
    package = "jspsychr",
    edit = FALSE,
    create_dir = TRUE
  )
}