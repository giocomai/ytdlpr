% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/yt_trim_with_text.R
\name{yt_trim_with_text}
\alias{yt_trim_with_text}
\title{Trim video files, including text overlay with basic information}
\usage{
yt_trim_with_text(
  subtitles_df,
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
  ...
)
}
\arguments{
\item{subtitles_df}{A data frame with subtitles, typically generated with a
combination of \code{\link[=yt_read_vtt]{yt_read_vtt()}} and \code{\link[=yt_filter]{yt_filter()}}. See examples.}

\item{only_local}{Defaults to TRUE. If FALSE, downloads missing video files.}

\item{font}{Defaults to "Mono".}

\item{fontcolor}{Defaults to "white".}

\item{fontsize}{Defaults to 32.}

\item{box}{Defaults to 1.}

\item{boxcolor}{Defaults to "black".}

\item{boxopacity}{Defaults to 0.5}

\item{boxborderw}{Defaults to 5}

\item{position_x}{Defaults to 10}

\item{position_y}{Defaults to 10}

\item{yt_base_folder}{Base folder, defaults to NULL. Can be set with
\code{\link[=yt_set_base_folder]{yt_set_base_folder()}}}

\item{...}{Passed to \code{\link[=yt_trim]{yt_trim()}}}
}
\value{
Nothing, used for side effects.
}
\description{
Arguments taken from \href{https://ffmpeg.org/ffmpeg-filters.html#drawtext}{FFMPEG's drawtext filter}
}
\examples{
\dontrun{
yt_get(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P",
  auto_subs = TRUE
) |> # download subtitles
  yt_read_vtt() |> # read them
  yt_filter(pattern = "rover") |> # keep only those with "rover" in the text
  dplyr::slice_sample(n = 2) |> # keep two, as this is only an example
  yt_trim_with_text(only_local = FALSE) # download video files and json files and trim video
}
}
