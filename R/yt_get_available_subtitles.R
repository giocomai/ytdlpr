#' Checks with clips have subtitles or automatic captions based on info json
#' file
#'
#' @param info_json_df Defaults to NULL. Generally created with
#'   `yt_read_info_json()`. If not given, either `yt_id` or `playlist` must be
#'   given. If given, both `yt_id` and `playlist` are ignored.
#' @param sub_lang Defaults to "en", subtitles language.
#' @param automatic_captions Defaults to TRUE. If TRUE, checks if subtitles are
#'   available as "automatic captions".
#' @param subtitles Defaults to TRUE. If TRUE, checks if subtitles are available
#'   as (manually added or approved) "subtitles".
#' @param yt_id YouTube video identifier. Ignored if `info_json_df` given.
#' @param playlist YouTube list. Ignored if `info_json_df` given.
#'
#' @return A data frame with three columns, `yt_id`, `sub_lang`, and `sub_type`
#'   (`sub_type` can either be `automatic_captions` or `subtitles`).
#' @export
#'
#' @examples
#' \dontrun{
#' yt_get_available_subtitles(
#'   playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbtMcDKmT2dRAfjmSFwOt1Vj"
#' )
#' }
yt_get_available_subtitles <- function(info_json_df = NULL,
                                       sub_lang = "en",
                                       automatic_captions = TRUE,
                                       subtitles = TRUE,
                                       yt_id = NULL,
                                       playlist = NULL) {
  if (is.null(info_json_df)) {
    info_json_df <- yt_get(
      yt_id = yt_id,
      playlist = playlist,
      info_json = TRUE
    ) |>
      yt_read_info_json()
  }

  if (subtitles) {
    subs_df <- info_json_df |>
      dplyr::select("yt_id", "subtitles") |>
      dplyr::mutate(subtitles = purrr::map(subtitles, \(x) x[x == sub_lang])) |>
      tidyr::unnest(subtitles) |>
      dplyr::filter(
        subtitles %in% sub_lang,
        is.na(subtitles) == FALSE
      ) |>
      dplyr::mutate(sub_type = "subtitles") |>
      dplyr::rename(sub_lang = subtitles)
  } else {
    subs_df <- NULL
  }


  if (automatic_captions) {
    ac_df <- info_json_df |>
      dplyr::select("yt_id", "automatic_captions") |>
      dplyr::mutate(automatic_captions = purrr::map(automatic_captions, \(x) x[x == sub_lang])) |>
      tidyr::unnest(automatic_captions) |>
      dplyr::filter(
        automatic_captions %in% sub_lang,
        is.na(automatic_captions) == FALSE
      ) |>
      dplyr::mutate(sub_type = "automatic_captions") |>
      dplyr::rename(sub_lang = automatic_captions)
  } else {
    ac_df <- NULL
  }

  dplyr::bind_rows(
    subs_df,
    ac_df
  )
}
