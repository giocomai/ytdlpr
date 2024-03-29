% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/yt_get_local.R
\name{yt_get_local}
\alias{yt_get_local}
\title{Lists locally available files that can be attributed to a video id}
\usage{
yt_get_local(
  yt_id = NULL,
  playlist = NULL,
  file_extension = NULL,
  yt_base_folder = NULL
)
}
\arguments{
\item{yt_id}{Url or unique identifier of a YouTube video.}

\item{playlist}{Playlist, either as full url from Youtube or as id.}

\item{file_extension}{Defaults to NULL. Only file names with the given
extension are returned.}

\item{yt_base_folder}{Base folder, defaults to NULL. Can be set with
\code{\link[=yt_set_base_folder]{yt_set_base_folder()}}}
}
\value{
A data frame, with two columns, \code{yt_id} and \code{path}.
}
\description{
Lists locally available files that can be attributed to a video id
}
\examples{
\dontrun{
yt_get_local()

yt_get_local(
  yt_id = "WXPBOfRtXQE",
  file_extension = "webm"
)
}
}
