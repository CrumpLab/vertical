#' Initialize a **vertical** project
#'
#' This function is called when a **vertical** R project is created.
#'
#' @param path Name (and location) of package. Must be a valid R package name.
#' @param init_git Initialize a git repository? (TRUE)
#' @param init_data Initialize data? (TRUE)
#' @param init_ms Initialize APA6 manuscript R Markdown template? (TRUE)
#' @param init_som Initialize supplementary materials R Markdown template? (TRUE)
#' @param init_slides Initialize an R Markdown slide template? (TRUE)
#' @param init_poster Initialize an R Markdown poster template? (TRUE)
#' @param init_exp Initialize a jsPsych experiment template? (FALSE)
#' @param ...  Not used.
#'
#' @export
vertical_project <- function(path = NULL,
                             init_git = TRUE,
                             init_data = TRUE,
                             init_ms = TRUE,
                             init_som = TRUE,
                             init_slides = TRUE,
                             init_poster = TRUE,
                             init_exp = FALSE,
                             ...) {
  if(is.null(path)) {
    rstudioapi::executeCommand('newProject', quiet = FALSE)
    return(usethis::ui_info("Opening RStudio Project Template, select New Directory, then Vertical Research Project"))
  }

  dots <- list(...)
  if (length(dots) == 0) {
    dots <- append(dots, list(
      init_git = init_git,
      init_data = init_data,
      init_ms = init_ms,
      init_som = init_som,
      init_slides = init_slides,
      init_poster = init_poster,
      init_exp = init_exp
    ))
  }
  usethis::create_package(path)
  setwd(path)
  usethis::use_template(template = "_pkgdown.yml",
                        package = "vertical")
  if (dots$init_git) {
    git2r::init()
    usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))
  }
  if (dots$init_data) init_data()
  if (dots$init_ms) init_papaja()
  if (dots$init_slides) init_slides()
  if (dots$init_poster) init_poster()
  if (dots$init_exp) init_jspsych()
  if (dots$init_som) init_som()

}

init_data <- function() {
  usethis::use_directory("data-raw", ignore = TRUE)
  usethis::use_template(
    template = "preprocess.R",
    save_as = "data-raw/preprocess.R",
    package = "vertical"
  )
  usethis::use_template(
    template = "data.R",
    save_as = "R/data.R",
    data = list(dataname = "mydata"),
    package = "vertical"
  )
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
init_som <- function() {
  usethis::use_directory("vignettes")
  usethis::use_template(
    template = "article.Rmd",
    save_as = "vignettes/som.Rmd",
    data = list(vignette_title="Supplementary analyses",
                Package = basename(getwd())),
    package = "usethis"
  )
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
