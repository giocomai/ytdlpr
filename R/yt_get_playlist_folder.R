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
#' yt_get_playlist_folder()
yt_get_playlist_folder <- function(playlist,
                                   yt_base_folder = NULL) {
  yt_base_folder <- yt_get_base_folder(path = yt_base_folder)

  playlist <- stringr::str_remove(
    string = playlist,
    pattern = stringr::fixed("https://www.youtube.com/playlist?list=")
  )

  playlist_folder <- fs::path(
    yt_base_folder,
    fs::path_sanitize(playlist)
  )

  fs::dir_create(playlist_folder)
}
