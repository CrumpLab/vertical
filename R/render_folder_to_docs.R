#' Render rmd ina folder to docs
#'
#' @param folder_name string, name of folder , eg "slides"
#' @param dest_folder string, name of destination folder, default = "docs
#'
#' @return rendered rmd files in destination folder
#' @export
#'
render_folder_to_docs <- function(folder_name,
                                  dest_folder = "docs"){

  file_names <- list.files(folder_name, pattern = "\\.Rmd$")

  for(i in file_names){
    rmarkdown::render(paste(folder_name,file_names[1],sep="/"),
                      output_dir = paste(".",dest_folder,folder_name,sep="/"))
  }
}


