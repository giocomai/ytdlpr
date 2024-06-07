#' Concatenated trimmed video files in a single video clip
#'
#' @param trimmed_df A data frame, typically generated as output of `yt_trim()` or `yt_trim_with_text()`.
#' @param sort_by_date Defaults to FALSE. If TRUE, retrieves (and, if necessary, downloads) info files for all video clips, and reads them with `yt_read_info_json()` in order to get information about the published time.
#' @param info_df Defaults to NULL. If given, a data frame typically generated with `yt_read_info_json()`.
#' @param overwrite Defaults to FALSE. If TRUE, overwrites concatenated file if it already exists.
#' @inheritParams yt_trim
#'
#' @return The path of the generated video clip.
#' @export
yt_concatenate <- function(trimmed_df,
                           sort_by_date = FALSE,
                           info_df = NULL,
                           destination_filename = "concatenated",
                           destination_folder = "0_concatenated_video",
                           destination_path = NULL,
                           overwrite = FALSE,
                           yt_base_folder = NULL) {
  if (is.null(destination_path)) {
    destination_path <- fs::dir_create(
      yt_get_base_folder(path = yt_base_folder),
      destination_folder
    )
  }

  trimmed_df <- trimmed_df |>
    dplyr::filter(fs::file_exists(destination_file))

  if (sort_by_date) {
    if (is.null(info_df)) {
      info_df <- yt_read_info_json(yt_get(
        yt_id = unique(trimmed_df[["yt_id"]]),
        info_json = TRUE,
        yt_base_folder = yt_base_folder
      ))
    }

    trimmed_df <- trimmed_df |>
      dplyr::left_join(
        y = info_df,
        by = "yt_id"
      ) |>
      dplyr::arrange(upload_date)
  }

  txt_file <- fs::path(destination_path, destination_filename, ext = "txt")
  mp4_file <- fs::path(destination_path, destination_filename, ext = "mp4")

  if (overwrite == FALSE) {
    if (fs::file_exists(txt_file)) {
      cli::cli_abort("{.path txt_file} exists. Please remove or set {.var overwrite} to {.var {TRUE}}.")
    }
    if (fs::file_exists(mp4_file)) {
      cli::cli_abort("{.path mp4_file} exists. Please remove or set {.var overwrite} to {.var {TRUE}}.")
    }
  }

  stringr::str_c("file ", shQuote(trimmed_df[["destination_file"]])) |>
    readr::write_lines(txt_file)

  system(
    paste0(
      "ffmpeg -f concat -safe 0 -c:a aac -i ",
      txt_file,
      " ",
      mp4_file
    )
  )
  cli::cli_inform(message = "Video clip generated: {.path {mp4_file}}")

  invisible(mp4_file)
}
