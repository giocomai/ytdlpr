#' Read vtt subtitles
#'
#' @param path Path to one or more subtitle file in the vtt format. If a data frame is used as input, a column named "path" in that data frame will be used as source.
#'
#' @return A data frame with
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_subtitles_playlist(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
#' ) |>
#'   yt_read_vtt()
#' }
yt_read_vtt <- function(path) {
  if (is.data.frame(path)) {
    if ("path" %in% colnames(path)) {
      path <- path[["path"]]
    } else {
      cli::cli_abort("The {.arg path} argument must either be a vector, or a data frame with a with a {.val path} column.")
    }
  }

  purrr::map(
    .progress = TRUE,
    .x = path,
    .f = function(current_path) {
      input_text <- readr::read_lines(
        file = current_path,
        progress = FALSE
      )

      current_sub_lang <- input_text[[3]] |>
        stringr::str_remove("sub_lang: ")

      current_title <- current_path |>
        fs::path_file() |>
        stringr::str_remove(pattern = " \\[.*$")

      current_id <- current_path |>
        stringr::str_remove("\\].*$") |>
        stringr::str_extract(pattern = "\\[.*$") |>
        stringr::str_remove("\\[")

      tibble::tibble(vtt = input_text) |>
        dplyr::filter(.data[["vtt"]] != "" & .data[["vtt"]] != " ") |>
        dplyr::mutate(timestamp = stringr::str_extract(
          string = .data[["vtt"]],
          pattern = "[0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3}"
        )) |>
        dplyr::mutate(position = dplyr::if_else(
          condition = is.na(.data[["timestamp"]]),
          true = NA_character_,
          false = stringr::str_remove(
            string = .data[["vtt"]],
            pattern = "[0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3}"
          )
        )) |>
        dplyr::mutate(
          line_id = as.numeric(is.na(.data[["timestamp"]]) == FALSE & !is.na(stats::lag(.data[["timestamp"]])))
        ) |>
        dplyr::mutate(line_id = cumsum(.data[["line_id"]])) |>
        dplyr::mutate(
          drop = stringr::str_detect(
            string = .data[["vtt"]],
            pattern = stringr::fixed("><c>")
          )
        ) |>
        dplyr::group_by(.data[["line_id"]]) |>
        dplyr::mutate(keep = sum(.data[["drop"]]) == 0) |>
        dplyr::filter(.data[["keep"]]) |>
        dplyr::filter(.data[["line_id"]] > 0) |>
        dplyr::mutate(
          text = dplyr::if_else(condition = is.na(.data[["timestamp"]]),
            true = .data[["vtt"]],
            false = ""
          )
        ) |>
        dplyr::summarise(
          text = stringr::str_c(.data[["text"]],
            collapse = " "
          ) |>
            stringr::str_squish(),
          start_time = stringr::str_extract(
            string = .data[["timestamp"]][is.na(.data[["timestamp"]]) == FALSE],
            pattern = "[0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3}"
          ),
        ) |>
        dplyr::mutate(line_id = dplyr::row_number()) |>
        dplyr::mutate(
          yt_id = current_id,
          sub_lang = current_sub_lang
        ) |>
        dplyr::relocate("yt_id", "sub_lang")
    }
  ) |>
    purrr::list_rbind()
}
