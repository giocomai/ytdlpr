#' Filter subtitles and link back the original source
#'
#' @param pattern A character string.
#' @param ignore_case Defaults to TRUE.
#' @param regex Defaults to TRUE.
#' @param subtitles_df Defaults to NULL. If given must be a data frame,
#'   typically generated with `yt_get_local_subtitles()`.
#' @param lag Defaults to `-3`. Refers to the number of seconds before or after
#'   the start time as recorded in the subtitles. Minus three seems to generally
#'   be a good default.
#' @inheritParams yt_get_local_subtitles
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_subtitles_playlist(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
#' )
#'
#' subtitles_df <- yt_get_local_subtitles(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
#' ) |>
#'   yt_read_vtt()
#'
#' yt_filter(
#'   pattern = "rover",
#'   subtitles_df = subtitles_df
#' )
#' }
#'
#' @importFrom rlang .data
yt_filter <- function(pattern,
                      ignore_case = TRUE,
                      regex = TRUE,
                      playlist = NULL,
                      subtitles_df = NULL,
                      sub_lang = NULL,
                      sub_format = "vtt",
                      lag = -3,
                      yt_base_folder = NULL) {
  if (is.null(subtitles_df)) {
    subtitles_df <- yt_get_local_subtitles(
      playlist = playlist,
      sub_lang = sub_lang,
      sub_format = sub_format,
      yt_base_folder = yt_base_folder
    ) |>
      yt_read_vtt()
  }

  if (regex) {
    filter_pattern <- stringr::regex(pattern = pattern, ignore_case = ignore_case)
  } else {
    filter_pattern <- stringr::fixed(pattern = pattern, ignore_case = ignore_case)
  }

  subtitles_df |>
    dplyr::filter(stringr::str_detect(
      string = .data[["text"]],
      pattern = filter_pattern
    )) |>
    dplyr::group_by(.data[["yt_id"]], .data[["line_id"]]) |>
    dplyr::mutate(
      start_time_sec =
        sum(
          lubridate::hms(.data[["start_time"]]) |>
            lubridate::period_to_seconds() |>
            round(digits = 0),
          lag
        )
    ) |>
    dplyr::mutate(link = stringr::str_c(
      "https://youtu.be/",
      .data[["yt_id"]],
      "?t=",
      .data[["start_time_sec"]]
    )) |>
    dplyr::select(-.data[["start_time_sec"]]) |>
    dplyr::ungroup()
}
