vertical_project <- function(path, ...) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  #copy all vertical template files
  file.copy(list.files(system.file("vertical", package="vertical"),
                       full.names = TRUE),
            path, recursive=TRUE, overwrite=TRUE)

  # copy papaja template to manuscript folder
  try(rmarkdown::draft(paste(path,"/manuscript/manuscript.Rmd",sep=""),
                   template="apa6", package="papaja", edit=FALSE, create_dir=FALSE))

  # copy latest jspsych release as .zip to experiments folder
  end_point <- "repos/jspsych/jsPsych/releases/latest"
  response <- devtools:::github_GET(end_point)
  latest_tag_name <- response$assets[[1]]$browser_download_url
  download.file(url = latest_tag_name,file.path("experiments", basename(latest_tag_name)))

}


#response$assets[[1]]$browser_download_url
