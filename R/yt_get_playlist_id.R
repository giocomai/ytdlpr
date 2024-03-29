#' Get all Youtube identifiers for a given playlist
#'
#' @param playlist The full url of a Youtube playlist.
#' @param update Defaults to FALSE. If FALSE, data is returned immediately if
#'   previously stored. If TRUE, it checks again the playlist on Youtube to see
#'   if new content has been added.
#' @inheritParams yt_get_playlist_folder
#'
#' @return A data frame (a tibble) with a single column named `yt_id`.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_playlist_id(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbtMcDKmT2dRAfjmSFwOt1Vj"
#' )
#' }
yt_get_playlist_id <- function(playlist,
                               update = FALSE,
                               yt_base_folder = NULL) {
  playlist_folder <- yt_get_playlist_folder(
    playlist = playlist,
    yt_base_folder = yt_base_folder
  )

  archive_file <- fs::path(playlist_folder, "archive.txt")

  if (fs::file_exists(archive_file) & update == FALSE) {
    # do nothing
  } else {
    yt_command <- stringr::str_c(
      "yt-dlp --skip-download --force-write-archive --download-archive",
      archive_file,
      playlist,
      sep = " "
    )

    system(command = yt_command)
  }

  readr::read_lines(file = archive_file) |>
    stringr::str_remove("youtube ") |>
    tibble::enframe(name = NULL, value = "yt_id")
}
