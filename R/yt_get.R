#' Retrieve video or write_subs from a playlist or by id
#'
#' If `write_subs` or `auto_subs` is set to TRUE, it checks that the
#' subtitles in the language set with `sub_lang` are available. In all other
#' cases, by defaults, it skips ' downloads if *any* previous file associated
#' with a given video identifier has ' been downloaded. Set `check_previous` to
#' FALSE to always download files.
#'
#' Argument definition are quoted from the original yt-dlp project.
#'
#' @param yt_id YouTube identifier of a video or full url to a video. Normally a
#'   vector, but if a data frame is given, `yt_id` column is taken as input
#'   (useful for pipe-based workflows).
#' @param subs Defaults to FALSE. "Write subtitle file".
#' @param auto_subs Defaults to FALSE "Write automatically generated
#'   subtitle file".
#' @param check_previous Defaults to TRUE. If FALSE, input is always downloaded.
#'   If TRUE, and `subs` is TRUE, it checks that the requested language is
#'   locally available. If subtitles is set to FALSE, and only one of the write
#'   options is enabled, it checks for the local availability of relevant files.
#'   For some options, the presence of *any* local file associated with a given
#'   id prevents further downloads associated with it.
#' @param sub_lang Defaults to "en". If more than one, can be given as comma
#'   separated two letter codes, or a as vector.
#' @param sub_format Defaults to "vtt". Other formats not yet supported.
#' @param video Defaults to FALSE. Download the video files.
#' @param info_json Defaults to FALSE. "Write video metadata to a .info.json
#'   file"
#' @param thumbnail Defaults to FALSE. "Write thumbnail image to disk"
#' @param description Defaults to FALSE. "Write video description to a
#'   .description file"
#' @param comments Defaults to FALSE. "Retrieve video comments to be placed in
#'   the infojson."
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
#' @param custom_binary Defaults to NULL. If given, path to executable `yt-dlp`.
#' @inheritParams yt_get_playlist_folder
#'
#' @return A data frame, with details about locally available subtitles.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbtMcDKmT2dRAfjmSFwOt1Vj"
#' )
#'
#' yt_get(
#'   yt_id = "https://youtu.be/WXPBOfRtXQE",
#'   subtitles = TRUE,
#'   video = TRUE,
#'   description = TRUE,
#'   info_json = TRUE
#' )
#' }
yt_get <- function(
  yt_id = NULL,
  playlist = NULL,
  check_previous = TRUE,
  sub_lang = "en",
  sub_format = "vtt",
  subs = FALSE,
  auto_subs = FALSE,
  video = FALSE,
  description = FALSE,
  info_json = FALSE,
  comments = FALSE,
  thumbnail = FALSE,
  min_sleep_interval = 1,
  max_sleep_interval = 8,
  sleep_subtitles = 2,
  custom_options = "",
  custom_binary = NULL,
  yt_base_folder = NULL
) {
  if (is.null(yt_id) & is.null(playlist)) {
    cli::cli_abort("Either `yt_id` or `playlist` must be given.")
  }

  if (is.data.frame(yt_id)) {
    yt_id <- unique(yt_id[["yt_id"]])
  }

  if (length(sub_lang) > 1) {
    sub_lang <- stringr::str_flatten(string = sub_lang, collapse = ",")
  }

  playlist_folder <- yt_get_playlist_folder(
    playlist = playlist,
    yt_base_folder = yt_base_folder
  )

  archive_file <- fs::path(playlist_folder, "archive.txt")

  if (check_previous) {
    if (is.null(playlist) == FALSE) {
      playlist_df <- yt_get_playlist_id(playlist = playlist)
    } else {
      archive_file <- fs::path(
        yt_get_base_folder(path = yt_base_folder),
        "archive.txt"
      )
      playlist_df <- tibble::tibble(yt_id = yt_extract_id(yt_id))
    }

    if (subs | auto_subs) {
      previous_df <- yt_get_local_subtitles(
        yt_id = yt_id,
        playlist = playlist,
        sub_format = sub_format,
        yt_base_folder = yt_base_folder
      ) |>
        dplyr::filter(
          .data[["sub_lang"]] %in% !!sub_lang
        )
    } else if (video) {
      previous_df <- yt_get_local(
        file_extension = "webm|mp4|mkv",
        yt_id = yt_id,
        playlist = playlist,
        yt_base_folder = yt_base_folder
      )
    } else if (info_json) {
      previous_df <- yt_get_local(
        file_extension = "info\\.json",
        yt_id = yt_id,
        playlist = playlist,
        yt_base_folder = yt_base_folder
      )
    } else if (description) {
      previous_df <- yt_get_local(
        file_extension = "description",
        yt_id = yt_id,
        playlist = playlist,
        yt_base_folder = yt_base_folder
      )
    } else {
      previous_df <- yt_get_local(
        yt_id = yt_id,
        playlist = playlist,
        yt_base_folder = yt_base_folder
      )
    }

    playlist_to_download_df <- playlist_df |>
      dplyr::distinct(.data[["yt_id"]]) |>
      dplyr::anti_join(
        y = previous_df |>
          dplyr::distinct(.data[["yt_id"]]),
        by = "yt_id"
      )
  } else {
    playlist_to_download_df <- tibble::tibble(yt_id = c(yt_id, playlist))
  }

  if (nrow(playlist_to_download_df) == 0) {
    return(previous_df)
  }

  batch_file_path <- fs::file_temp(ext = "txt")

  readr::write_lines(
    x = playlist_to_download_df[["yt_id"]],
    file = batch_file_path
  )

  yt_command_params <- custom_options

  if (subs) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--write-subs",
      sep = " "
    )
  }

  if (video == FALSE) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--skip-download",
      sep = " "
    )
  }

  if (description) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--write-description",
      sep = " "
    )
  }

  if (comments) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--write-comments",
      sep = " "
    )
  }

  if (thumbnail) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--write-thumbnail  ",
      sep = " "
    )
  }

  if (auto_subs) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--write-auto-sub",
      sep = " "
    )
  }

  if (info_json) {
    yt_command_params <- stringr::str_c(
      yt_command_params,
      "--write-info-json ",
      sep = " "
    )
  }

  if (is.null(custom_binary)) {
    binary_command <- "yt-dlp"
  } else {
    binary_command <- custom_binary
  }

  yt_command <- stringr::str_c(
    binary_command,
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

  if (subs | auto_subs) {
    yt_get_local_subtitles(
      yt_id = yt_id,
      playlist = playlist,
      sub_format = sub_format,
      yt_base_folder = yt_base_folder
    ) |>
      dplyr::filter(sub_lang %in% sub_lang)
  } else if (video) {
    previous_df <- yt_get_local(
      file_extension = "webm|mp4|mkv",
      yt_id = yt_id,
      playlist = playlist,
      yt_base_folder = yt_base_folder
    )
  } else if (info_json) {
    previous_df <- yt_get_local(
      file_extension = "info\\.json",
      yt_id = yt_id,
      playlist = playlist,
      yt_base_folder = yt_base_folder
    )
  } else {
    yt_get_local(
      yt_id = yt_id,
      playlist = playlist,
      yt_base_folder = yt_base_folder
    )
  }
}
