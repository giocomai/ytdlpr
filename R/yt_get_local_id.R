#' Lists locally available files that can be attributed to a video id
#'
#' @param file_extension Defaults to NULL. Only file names with the given
#'   extension are returned.
#' @inheritParams yt_get_playlist_folder
#' @inheritParams yt_extract_id
#'
#' @return A data frame, with two columns, `yt_id` and `path`.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_local_id()
#'
#' yt_get_local_id(
#'   yt_id = "WXPBOfRtXQE",
#'   file_extension = "webm"
#' )
#' }
yt_get_local_id <- function(yt_id = NULL,
                            playlist = NULL,
                            file_extension = NULL,
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

  if (is.null(file_extension) == FALSE) {
    all_files_v <- all_files_v[stringr::str_ends(string = all_files_v, pattern = file_extension)]
  }

  yt_id_df <- tibble::tibble(path = all_files_v) |>
    dplyr::mutate(yt_id = stringr::str_extract(
      string = .data[["path"]],
      pattern = "(?<=\\[)[[:print:]]{11}]\\."
    ) |>
      stringr::str_remove(pattern = "]\\.$")) |>
    dplyr::filter(is.na(.data[["yt_id"]]) == FALSE) |>
    dplyr::relocate("yt_id", "path")

  if (is.null(yt_id) == FALSE) {
    yt_id_df <- yt_id_df |>
      dplyr::filter(.data[["yt_id"]] %in% yt_extract_id(!!yt_id))
  }

  yt_id_df
}
