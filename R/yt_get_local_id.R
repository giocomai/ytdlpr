#' Lists locally available files that can be attributed to a video id
#'
#' @inheritParams yt_get_playlist_folder
#'
#' @return A data frame, with two columns, `yt_id` and `path`.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_local_id()
#' }
yt_get_local_id <- function(playlist = NULL,
                            yt_base_folder = NULL) {
  if (is.null(playlist) == FALSE) {
    folder_path <- yt_get_playlist_folder(
      playlist = playlist,
      yt_base_folder = yt_base_folder
    )
  } else {
    folder_path <- yt_get_base_folder(path = yt_base_folder)
  }

  all_files_v <- fs::dir_ls(
    path = folder_path,
    all = FALSE,
    recurse = TRUE,
    type = "file"
  )

  tibble::tibble(path = all_files_v) |>
    dplyr::mutate(yt_id = stringr::str_extract(
      string = .data[["path"]],
      pattern = "(?<=\\[)[[:print:]]{11}]\\."
    ) |>
      stringr::str_remove(pattern = "]\\.$")) |>
    dplyr::filter(is.na(.data[["yt_id"]]) == FALSE) |>
    dplyr::relocate(.data[["yt_id"]], .data[["path"]])
}
