#' Read info json files, and extract key data in a data frame
#'
#' @param path Path to one or more subtitle file in the json format, such as those downloaded by `yt_get(info_json =? TRUE)`. If a data frame is used as input, a column named "path" in that data frame will be used as source.
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P",
#'   info_json = TRUE
#' ) |>
#'   yt_read_info_json()
#' }
yt_read_info_json <- function(path) {
  if (is.data.frame(path)) {
    if ("path" %in% colnames(path)) {
      path <- path[["path"]]
    } else {
      cli::cli_abort("The {.arg path} argument must either be a vector, or a data frame with a with a {.val path} column.")
    }
  }

  path <- path[stringr::str_ends(string = path, pattern = "\\.info\\.json")]

  purrr::map(
    .progress = TRUE,
    .x = path,
    .f = function(current_path) {
      current_json_l <- yyjsonr::read_json_file(filename = current_path)

      tibble::tibble(
        yt_id = current_json_l |>
          purrr::pluck("id"),
        title = current_json_l |>
          purrr::pluck("title"),
        upload_date = current_json_l |>
          purrr::pluck("upload_date") |>
          lubridate::ymd(),
        duration = current_json_l |>
          purrr::pluck("duration"),
        language = current_json_l |>
          purrr::pluck("language"),
        description = current_json_l |>
          purrr::pluck("description"),
        view_count = current_json_l |>
          purrr::pluck("view_count"),
        categories = current_json_l |>
          purrr::pluck("categories") |>
          list(),
        tags = current_json_l |>
          purrr::pluck("tags") |>
          list(),
        subtitles = extract_captions_from_json(current_json_l, x = "subtitles"),
        automatic_captions = extract_captions_from_json(current_json_l, "automatic_captions"),
        ext = current_json_l |>
          purrr::pluck("ext"),
        width = current_json_l |>
          purrr::pluck("width"),
        height = current_json_l |>
          purrr::pluck("height"),
        epoch = current_json_l |>
          purrr::pluck("epoch"),
        retrieved_at = fs::file_info(current_path)[["birth_time"]]
      )
    }
  ) |>
    purrr::list_rbind()
}
