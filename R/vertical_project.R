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
    usethis::use_git(message = "Initial commit")
  }

  # pkgdown template
  vertical_pkgdown <- system.file("vertical/_pkgdown.yml", package = "vertical")
  base::file.copy(vertical_pkgdown, "_pkgdown.yml")

  # papaja manuscript
  if (dots$init_ms) {
    usethis::use_directory("manuscript", ignore = TRUE)
    rmarkdown::draft(
      file = "manuscript/manuscript.Rmd",
      template = "apa6",
      package = "papaja",
      edit = FALSE,
      create_dir = FALSE
    )
  }

  # supplementary analysis file
  if (dots$init_som) {
    usethis::use_article("Supplemental_1", title = "Supplementary analyses")
  }

  # Slides
  if (dots$init_slides) {
    usethis::use_directory("slides", ignore = TRUE)
    rmarkdown::draft(
      file = "slides/slides.Rmd",
      template = "slidy",
      package = "vertical",
      edit = FALSE,
      create_dir = FALSE
    )
  }

  # Poster
  if (dots$init_poster) {
    usethis::use_directory("posters", ignore = TRUE)
    rmarkdown::draft(
      file = "posters/poster.Rmd",
      template = "posterdown_html",
      package = "posterdown",
      edit = FALSE,
      create_dir = FALSE
    )
  }

  # Data
  usethis::use_data_raw()

  # Experiments
  if (dots$init_exp) {
    usethis::use_directory("experiments", ignore = TRUE)
    usethis::use_directory("experiments/experiment-1")
    response <- devtools:::github_GET("repos/jspsych/jsPsych/releases/latest")  # [TODO] rid triple colon
    latest_tag_name <- response$assets[[1]]$browser_download_url
    utils::download.file(url = latest_tag_name, file.path("experiments", basename(latest_tag_name)))
    utils::unzip(
      file.path("experiments", basename(latest_tag_name)),
      exdir = file.path("experiments", gsub(".zip", "", basename(latest_tag_name)))
    )
    vertical_jspsych <- system.file("vertical/experiment.html", package = "vertical")
    base::file.copy(vertical_jspsych, "experiments/experiment-1/index.html")
  }

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
  # [TODO] file paths for references throw errors here
  try(
    {rmarkdown::render(
      "manuscript/manuscript.Rmd",
      output_dir = "docs/manuscript",
      output_file = "manuscript.pdf"
    )},
    silent = TRUE
  )
  if (dir.exists("experiments")) {
    dir.create('docs/experiments')
    file.copy("experiments", "docs", recursive=TRUE)
  }
}
