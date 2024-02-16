#' Extract YouTube identifier from an URL.
#'
#' @param yt_id Url or unique identifier of a YouTube video.
#'
#' @return A character vector of YouTube identifiers.
#' @export
#'
#' @examples
#' yt_extract_id("https://youtu.be/WXPBOfRtXQE?feature=shared")
#'
#' # if already an identifier, just returns it:
#' yt_extract_id("WXPBOfRtXQE")
yt_extract_id <- function(yt_id) {
  if (sum(purrr::map_lgl(.x = yt_id, .f = function(x) {
    nchar(x) == 11
  })) == length(yt_id)) {
    return(yt_id)
  }

  yt_id <- stringr::str_remove(
    string = yt_id,
    pattern = "\\?.*$"
  )

  yt_id <- stringr::str_extract(
    string = yt_id,
    pattern = "(?<=\\/)[[:print:]]{11}$"
  )

  yt_id
}
