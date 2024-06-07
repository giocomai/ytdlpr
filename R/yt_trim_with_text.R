#' Trim video files, including text overlay with basic information
#'
#' Arguments taken from [FFMPEG's drawtext filter](https://ffmpeg.org/ffmpeg-filters.html#drawtext)
#'
#' @param font Defaults to "Mono".
#' @param fontcolor Defaults to "white".
#' @param fontsize Defaults to 32.
#' @param box Defaults to 1.
#' @param boxcolor Defaults to "black".
#' @param boxopacity Defaults to 0.5
#' @param boxborderw Defaults to 5
#' @param position_x Defaults to 10
#' @param position_y Defaults to 10
#' @param ... Passed to [yt_trim()]
#' @inheritParams yt_trim
#'
#' @return Nothing, used for side effects.
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P",
#'   auto_subs = TRUE
#' ) |> # download subtitles
#'   yt_read_vtt() |> # read them
#'   yt_filter(pattern = "rover") |> # keep only those with "rover" in the text
#'   dplyr::slice_sample(n = 2) |> # keep two, as this is only an example
#'   yt_trim_with_text(only_local = FALSE) # download video files and json files and trim video
#' }
yt_trim_with_text <- function(subtitles_df,
                              only_local = TRUE,
                              font = "Mono",
                              fontcolor = "white",
                              fontsize = 32,
                              box = 1,
                              boxcolor = "black",
                              boxopacity = 0.5,
                              boxborderw = 5,
                              position_x = 10,
                              position_y = 10,
                              yt_base_folder = NULL,
                              ...) {
  trim_df <- yt_trim(
    subtitles_df = subtitles_df,
    only_local = only_local,
    yt_base_folder = yt_base_folder,
    simulate = TRUE,
    ...
  )

  purrr::walk(
    .progress = TRUE,
    .x = purrr::transpose(trim_df),
    .f = function(current) {
      if (only_local) {
        local_json_df <- yt_get_local(
          yt_id = current[["yt_id"]],
          file_extension = ".info.json"
        )
        if (nrow(local_json_df) == 0) {
          cli::cli_warn("Info json for video with id {.val {current[['yt_id']]}} missing, skipping.")
          return(invisible(NULL))
        }
        current_json_df <- local_json_df |>
          yt_read_info_json()
      } else {
        current_json_df <- yt_get(
          yt_id = current[["yt_id"]],
          info_json = TRUE
        ) |>
          yt_read_info_json()
      }


      text_v <- c(
        stringr::str_c("Date:  ", current_json_df[["upload_date"]]),
        stringr::str_c("Title: ", current_json_df[["title"]]),
        stringr::str_c("ID:    ", current[["yt_id"]]),
        stringr::str_c("Start: ", current[["start_time"]] |>
          stringr::str_remove(pattern = ".[[:digit:]]{3}$"))
      )

      text_temp_path <- fs::file_temp(ext = "txt")

      readr::write_lines(
        x = text_v,
        file = text_temp_path
      )

      ffmpeg_command <- stringr::str_c(
        "ffmpeg -y -i ",
        shQuote(current[["path"]]),
        " -vf ",
        "drawtext=font=",
        shQuote(font),
        ":textfile=",
        shQuote(text_temp_path),
        ":fontcolor=",
        fontcolor,
        ":fontsize=",
        fontsize,
        ":box=",
        box,
        ":boxcolor=",
        boxcolor,
        "@",
        boxopacity,
        ":boxborderw=",
        boxborderw,
        ":x=",
        position_x,
        ":y=",
        position_y,
        " -ss ",
        current[["start_time_string"]],
        " -to ",
        current[["end_time_string"]],
        " ",
        shQuote(current[["destination_file"]])
      )

      system(command = ffmpeg_command)
    }
  )

  invisible(trim_df)
}
