#' Set for the current session base folder where all retrieved files will be
#' stored
#'
#' @param path Defaults to NULL. If not set, checks if a path has been
#'   previously set, and if not, defaults to current folder.
#'
#' @return The given path (or, if left to NULL, the path previously set) is
#'   returned invisibly.
#' @export
#'
#' @examples
#' yt_set_base_folder(path = fs::path(
#'   fs::path_home_r(),
#'   "R",
#'   "ytdlpr"
#' ))
#' yt_get_base_folder()
yt_set_base_folder <- function(path) {
  Sys.setenv(yt_base_folder = path)
  invisible(path)
}

#' Retrieves base folder where all retrieved files will be stored for the
#' current session
#'
#' @param path Defaults to NULL. If not set, checks if a path has been
#'   previously set, and if not, defaults to current folder.
#'
#' @return The given path (or, if left to NULL, the path previously set) is
#'   returned invisibly.
#' @export
#'
#' @examples
#' yt_set_base_folder(path = fs::path(
#'   fs::path_home_r(),
#'   "R",
#'   "ytdlpr"
#' ))
#' yt_get_base_folder()
yt_get_base_folder <- function(path = NULL) {
  if (is.null(path)) {
    yt_base_folder <- Sys.getenv("yt_base_folder", unset = ".")
  } else {
    yt_base_folder <- path
  }
  if (fs::file_exists(yt_base_folder) == FALSE) {
    fs::dir_create(yt_base_folder)
    cli::cli_inform("Base folder created: {.path {yt_base_folder}}")
  }
  invisible(yt_base_folder)
}
