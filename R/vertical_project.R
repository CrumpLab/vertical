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

#' Build vertical project
#'
#' Build the website associated with a vertical project
#'
#' @export
build_vertical <- function() {
  pkgdown::clean_site()
  pkgdown::build_site()
  rmarkdown::render(
    "posters/poster.Rmd",
    output_dir = "docs/posters", output_file = "poster.html"
  )
  rmarkdown::render(
    "slides/slides.Rmd",
    output_dir = "docs/slides", output_file = "slides.html"
  )
  # Works, but throws error if file not created first
  file.create("manuscript/r-references.bib")
  rmarkdown::render(
    "manuscript/manuscript.Rmd",
    output_dir = "docs/manuscript"
  )
  if (dir.exists("experiments")) {
    dir.create("docs/experiments")
    file.copy("experiments", "docs", recursive = TRUE)
  }
}
