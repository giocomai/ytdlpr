#' Trim video files so that it shows only the part with relevant subtitles
#'
#' @param subtitles_df A data frame with subtitles, typically generated with a
#'   combination of [yt_read_vtt()] and [yt_filter()]. See examples.
#' @param destination_folder Defaults to `0_trimmed_video`: trimmed video files
#'   will be stored inside a folder called `0_trimmed_video` inside your base
#'   folder as defined by `yt_base_folder` or options. If you want an absolute
#'   path, use the argument `destination_path` instead.
#' @param destination_path Defaults to NULL. Location where trimmed video files
#'   will be stored. If given, takes precedence over `destination_folder`.
#' @param duration Duration in seconds of the trimmed video. Defaults to 6.
#' @param simulate Defaults to FALSE. Similiarly to the same argument in
#'   `yt-dlp`, if set to TRUE nothing is actually done
#' @inheritParams yt_get_playlist_folder
#' @inheritParams yt_extract_id
#' @inheritParams yt_filter
#'
#' @return A data fram with details about the export and ffmpeg commmand. Mostly
#'   used for side effects (creates trimmed video files).
#' @export
#'
#' @examples
#' \dontrun{
#' filtered_subs_df <- yt_get(
#'   yt_id = "-0pPBAiJaYk",
#'   subtitles = TRUE,
#'   video = TRUE
#' ) |>
#'   yt_read_vtt() |>
#'   yt_filter(pattern = "community")
#'
#' yt_trim(filtered_subs_df)
#' }
yt_trim <- function(subtitles_df,
                    lag = -3,
                    duration = 6,
                    video_file_extension = "webm|mp4|mkv",
                    simulate = FALSE,
                    destination_folder = "0_trimmed_video",
                    destination_path = NULL,
                    yt_base_folder = NULL) {
  yt_id_v <- unique(subtitles_df[["yt_id"]])

  local_video_path <- yt_get_local_id(
    yt_id = yt_id_v,
    file_extension = video_file_extension,
    yt_base_folder = yt_base_folder
  )

  if (is.null(destination_path)) {
    destination_path <- fs::dir_create(
      yt_get_base_folder(path = yt_base_folder),
      destination_folder
    )
  }


  convert_df <- subtitles_df |>
    dplyr::select("yt_id", "start_time") |>
    dplyr::left_join(
      y = local_video_path,
      by = "yt_id"
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(start_time_period = sum(
      lubridate::hms(.data[["start_time"]]) |>
        lubridate::period_to_seconds(),
      lag
    ) |>
      lubridate::seconds_to_period()) |>
    dplyr::mutate(end_time_period = sum(
      start_time_period |>
        lubridate::period_to_seconds(),
      duration
    ) |>
      lubridate::seconds_to_period()) |>
    dplyr::mutate(
      start_time_string = stringr::str_c(
        stringr::str_c(
          stringr::str_pad(string = lubridate::hour(start_time_period), width = 2, side = "left", pad = 0),
          stringr::str_pad(string = lubridate::minute(start_time_period), width = 2, side = "left", pad = 0),
          stringr::str_pad(string = lubridate::second(start_time_period), width = 2, side = "left", pad = 0) |>
            (\(.) dplyr::if_else(condition = stringr::str_detect(string = ., pattern = stringr::fixed(".")),
              false = .,
              true = stringr::str_pad(string = ., width = 6, side = "right", pad = "0")
            ))(),
          sep = ":"
        )
      ),
      end_time_string = stringr::str_c(
        stringr::str_c(
          stringr::str_pad(string = lubridate::hour(end_time_period), width = 2, side = "left", pad = 0),
          stringr::str_pad(string = lubridate::minute(end_time_period), width = 2, side = "left", pad = 0),
          stringr::str_pad(string = lubridate::second(end_time_period), width = 2, side = "left", pad = 0) |>
            (\(.) dplyr::if_else(condition = stringr::str_detect(string = ., pattern = stringr::fixed(".")),
              false = .,
              true = stringr::str_pad(string = ., width = 6, side = "right", pad = "0")
            ))(),
          sep = ":"
        )
      )
    ) |>
    dplyr::mutate(destination_file = fs::path(
      destination_path,
      stringr::str_c(
        .data[["yt_id"]],
        "_",
        round(lubridate::period_to_seconds(.data[["start_time_period"]]), digits = 0),
        "_",
        duration
      ) |>
        fs::path_ext_set("mp4")
    )) |>
    dplyr::mutate(ffmpeg_command = stringr::str_c(
      "ffmpeg -y -i ",
      shQuote(.data[["path"]]),
      " -ss ",
      .data[["start_time_string"]],
      " -to ",
      .data[["end_time_string"]],
      " ",
      # "-c copy ",
      shQuote(destination_file)
    )) |>
    dplyr::ungroup() |>
    dplyr::distinct()

  if (simulate) {
    return(convert_df)
  }

  purrr::walk(
    .x = convert_df[["ffmpeg_command"]],
    .f = function(current_command) {
      system(current_command)
    }
  )

  convert_df
}
