#' Extract available languages in captions
#'
#' Used internally
#'
#' @param json_l A list object, resulting from a parsed .info.json file
#' @param x Type of data to extract. In practice, either "subtitles" or
#'   "automatic_captions"
#'
#' @return A list, with names of available languages
#'
#' @examples
#' \dontrun{
#' extract_captions_from_json(
#'   yyjsonr::read_json_file("path_to_json_file"),
#'   "automatic_captions"
#' )
#' }
extract_captions_from_json <- function(json_l, x) {
  captions_lang <- json_l |>
    purrr::pluck(x) |>
    names()
  if (length(captions_lang) == 0) {
    return(list(NA_character_))
  } else {
    return(list(captions_lang))
  }
}
