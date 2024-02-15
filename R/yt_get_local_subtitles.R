#' Check for the availability of local subtitles and return details in a data
#' frame
#'
#' @param sub_format Defaults to "vtt". File extension of the subtitle.
#' @param language Defaults to NULL. If not given, all local subtitles are
#'   returned. If given, only subtitles in the given language are returned.
#' @inheritParams yt_get_playlist_folder
#'
#' @return A data frame (a tibble) with details on locally available subtitle
#'   files.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_local_subtitles()
#' }
yt_get_local_subtitles <- function(playlist = NULL,
                                   language = NULL,
                                   sub_format = "vtt",
                                   yt_base_folder = NULL) {
  if (is.null(playlist) == FALSE) {
    subtitles_folder <- yt_get_playlist_folder(
      playlist = playlist,
      yt_base_folder = yt_base_folder
    )
  } else {
    subtitles_folder <- yt_get_base_folder(path = yt_base_folder)
  }

  all_subs_v <- fs::dir_ls(
    path = subtitles_folder,
    all = FALSE,
    recurse = TRUE,
    type = "file",
    glob = stringr::str_c("*.", sub_format)
  )

  subtitles_df <- tibble::tibble(path = all_subs_v) |>
    dplyr::mutate(metadata = stringr::str_extract(
      string = path,
      pattern = "\\[[[:print:]]+$"
    )) |>
    dplyr::mutate(title = fs::path_file(path) |>
      stringr::str_remove(stringr::fixed(metadata)) |>
      stringr::str_trim()) |>
    dplyr::mutate(metadata = metadata |>
      stringr::str_remove(stringr::fixed(stringr::str_c(".", sub_format, collapse = "")))) |>
    dplyr::mutate(
      language = metadata |>
        stringr::str_extract(pattern = "[[:alpha:]]{2}$"),
      yt_id = metadata |>
        stringr::str_extract(pattern = "(?<=\\[)[[:print:]]{11}"),
      playlist = path |>
        fs::path_dir() |>
        stringr::str_remove(subtitles_folder) |>
        stringr::str_remove(pattern = stringr::fixed("/")),
      sub_format = sub_format
    ) |>
    dplyr::select(
      yt_id,
      language,
      sub_format,
      title,
      playlist,
      path
    )

  if (is.null(language) == FALSE) {
    subtitles_df |>
      dplyr::filter(language %in% language)
  } else {
    subtitles_df
  }
}
