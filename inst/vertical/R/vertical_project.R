vertical_project <- function(path, ...) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(system.file("vertical", package="ptexamples"),
                       full.names = TRUE),
            path, recursive=TRUE, overwrite=TRUE)
}
