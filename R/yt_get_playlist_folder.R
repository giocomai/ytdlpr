#' Get local path to folder where files for the given playlist will be stored
#'
#' @param playlist Playlist, either as full url from Youtube or as id.
#' @param yt_base_folder Base folder, defaults to NULL. Can be set with
#'   [yt_set_base_folder()]
#'
#' @return Path to playlist folder.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_playlist_folder(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbtMcDKmT2dRAfjmSFwOt1Vj"
#' )
#' }
#'
yt_get_playlist_folder <- function(playlist,
                                   yt_base_folder = NULL) {
  yt_base_folder <- yt_get_base_folder(path = yt_base_folder)

  if (is.null(playlist)) {
    return(yt_base_folder)
  }

  if (stringr::str_detect(string = playlist, pattern = "list=")) {
    playlist_id <- stringr::str_extract(
      string = playlist,
      pattern = "(?<=list\\=)[[:print:]]+$"
    )
    playlist_path <- playlist_id
  } else {
    playlist_id <- playlist
    playlist_path <- stringr::str_remove(
      string = playlist,
      pattern = stringr::fixed("https://www.youtube.com/")
    )
  }

  playlist_folder <- fs::path(
    yt_base_folder,
    fs::path_sanitize(playlist_path)
  )

  if (fs::file_exists(playlist_folder) == FALSE) {
    fs::dir_create(playlist_folder)
    cli::cli_inform("Playlist folder created: {.path {playlist_folder}}")
  }

  playlist_folder
}
