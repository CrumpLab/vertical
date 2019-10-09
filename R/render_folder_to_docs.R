render_folder_to_docs <- function(folder_name,
                                  dest_folder = "docs",
                                  assets_folder){

  file_names <- list.files(folder_name, pattern = "\\.Rmd$")

  for(i in file_names){
    rmarkdown::render(paste(folder_name,file_names[1],sep="/"),
                      output_dir = paste(".",dest_folder,folder_name,sep="/"))
  }

  if (missing(assets_folder) == FALSE){

  }
}


