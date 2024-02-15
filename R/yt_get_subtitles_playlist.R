#' Retrieve subtitles from a playlist
#'
#' Argument definition from the original project.
#'
#' @param sub_lang Defaults to "en". If more than one, can be given as comma
#'   separated two letter codes, or a as vector.
#' @param sub_format Defaults to "vtt". Other formats not yet supported.
#' @param write_auto_sub "Write automatically generated subtitle file"
#' @param write_info_json "Write video metadata to a .info.json file (this may
#'   contain personal information)"
#' @param min_sleep_interval "Number of seconds to sleep before each download.
#'   This is the minimum time to sleep when used along with
#'   --max-sleep-interval"
#' @param max_sleep_interval "Maximum number of seconds to sleep. Can only be
#'   used along with --min-sleep-interval"
#' @param sleep_subtitles "Number of seconds to sleep before each subtitle
#'   download"
#' @param custom_options Defaults to an empty string. If given, it should
#'   correspond to parameters exactly as they would be used on command line. For
#'   a full list, see the [original
#'   documentation](https://github.com/yt-dlp/yt-dlp).
#' @inheritParams yt_get_playlist_folder
#'
#' @return Nothing, used for its side effects.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_subtitles_playlist(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbtMcDKmT2dRAfjmSFwOt1Vj"
#' )
#' }
yt_get_subtitles_playlist <- function(playlist,
                                      sub_lang = "en",
                                      sub_format = "vtt",
                                      write_auto_sub = TRUE,
                                      write_info_json = FALSE,
                                      min_sleep_interval = 1,
                                      max_sleep_interval = 8,
                                      sleep_subtitles = 2,
                                      custom_options = "",
                                      yt_base_folder = NULL) {
  playlist_folder <- yt_get_playlist_folder(
    playlist = playlist,
    yt_base_folder = yt_base_folder
  )

  archive_file <- fs::path(playlist_folder, "archive.txt")

  if (length(sub_lang) > 1) {
    sub_lang <- stringr::str_flatten(string = sub_lang, collapse = ",")
  }

  playlist_df <- yt_get_playlist_id(playlist = playlist)

  local_subtitles_df <- yt_check_local_subtitles(
    sub_format = sub_format,
    yt_base_folder = yt_base_folder
  ) |>
    dplyr::filter(language %in% sub_lang,
                  yt_id %in% playlist_df[["yt_id"]])

  playlist_to_download_df <- playlist_df |>
    dplyr::anti_join(
      y = local_subtitles_df |>
        dplyr::distinct(yt_id),
      by = "yt_id"
    )

  if (nrow(playlist_to_download_df) == 0) {
    return(local_subtitles_df)
  }

  batch_file_path <- fs::file_temp(ext = "txt")
  readr::write_lines(
    x = playlist_to_download_df[["yt_id"]],
    file = batch_file_path
  )

  yt_command_params <- stringr::str_c("--write-subs", custom_options, sep = " ")

  if (write_auto_sub) {
    yt_command_params <- stringr::str_c(yt_command_params, "--write-auto-sub", sep = " ")
  }

  if (write_info_json) {
    yt_command_params <- stringr::str_c(yt_command_params, "--write-info-json ", sep = " ")
  }

  yt_command <- stringr::str_c(
    "yt-dlp --skip-download",
    yt_command_params,
    "--paths",
    shQuote(playlist_folder),
    "--sub-lang",
    shQuote(sub_lang),
    "--min-sleep-interval",
    min_sleep_interval,
    "--max-sleep-interval",
    max_sleep_interval,
    "--sleep-subtitles",
    sleep_subtitles,
    "--batch-file",
    shQuote(string = batch_file_path),
    sep = " "
  )

  system(command = yt_command)

  yt_check_local_subtitles(
    sub_format = sub_format,
    yt_base_folder = yt_base_folder
  ) |>
    dplyr::filter(language %in% sub_lang)
}
