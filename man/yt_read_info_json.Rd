% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/yt_read_info_json.R
\name{yt_read_info_json}
\alias{yt_read_info_json}
\title{Read info json files, and extract key data in a data frame}
\usage{
yt_read_info_json(path)
}
\arguments{
\item{path}{Path to one or more subtitle file in the json format, such as those downloaded by \code{yt_get(info_json =? TRUE)}. If a data frame is used as input, a column named "path" in that data frame will be used as source.}
}
\value{
A data frame
}
\description{
Read info json files, and extract key data in a data frame
}
\examples{
\dontrun{
yt_get(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P",
  info_json = TRUE
) |>
  yt_read_info_json()
}
}
