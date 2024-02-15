#' Retrieve subtitles from a playlist
#'
#' Argument definition from the original project.
#'
#' @param sub_lang Defaults to "en". If more than one, can be given as comma
#'   separated two letter codes, or a as vector.
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

  playlist_df <- yt_get_playlist_id(playlist = playlist)

  yt_command_params <- stringr::str_c("--write-subs", custom_options, sep = " ")

  if (write_auto_sub) {
    yt_command_params <- stringr::str_c(yt_command_params, "--write-auto-sub", sep = " ")
  }

  if (write_info_json) {
    yt_command_params <- stringr::str_c(yt_command_params, "--write-info-json ", sep = " ")
  }

  if (length(sub_lang) > 1) {
    sub_lang <- stringr::str_flatten(string = sub_lang, collapse = ",")
  }

  purrr::walk(
    .progress = TRUE,
    .x = playlist_df[["yt_id"]],
    .f = function(current_yt_id) {
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
        shQuote(string = current_yt_id),
        sep = " "
      )

      system(command = yt_command)
    }
  )
}
