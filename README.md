
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ytdlpr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

ytdlpr wraps some functionalities of `yt-dlp` to facilitate their use in
R-based workflows. It is currently focused on retrieving and parsing
subtitles.

## Installation

You can install the development version of `ytdlpr` from
[GitHub](https://github.com/giocomai/ytdlpr) with:

``` r
remotes::install_github("giocomai/ytdlpr")
```

## Documentation

Let’s say we want to retrieve some information about [this
playlist](https://www.youtube.com/playlist?list=PLbyvawxScNbtMcDKmT2dRAfjmSFwOt1Vj)
of video files published by the European Space Agency (chosen at
random). The reference use case is about retrieving subtitles, but
documentation about other use cases will be added.

We will first need to set a base folder where all the files retrieved
with this package will be stored. I like to store such things under the
R folder of my home directory, so I may proceed as follows:

``` r
library("ytdlpr")

yt_set_base_folder(path = fs::path(
  fs::path_home_r(),
  "R",
  "ytdlpr" # you'd probably set something meaningful here, relevant to what you're downloading
))
```

Throughout the current session, this will be the main folder where I’ll
be storing files. If not set, it will default to storing things inside
the current working directory.

What happens next depends a bit on your starting point, i.e., if you
have a set of urls of individual videos or if you want to retrieve
subtitles about a whole playlist.

### Retrieve subtitles starting from single video urls/id

\[to do\]

### Retrieve subtitles starting from a playlist

A first step, that if not explicitly done will be performed implicitly
by other playlist-based functions is to retrieve all identifiers from
the given playlist.

``` r
yt_get_playlist_id(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
)
#> # A tibble: 7 × 1
#>   yt_id      
#>   <chr>      
#> 1 qlbBCymbdOM
#> 2 NpF75U10ewM
#> 3 FpFZJNM8cig
#> 4 YSfwPzWM-8o
#> 5 M2awfGQIEoU
#> 6 bF-ZLHetgJs
#> 7 kuAjDl0ACCA
```

Notice that the data are stored locally: unless the `update` argument in
`yt_get_playlist_id()` is set to TRUE, following calls to this function
will just retrieve locally stored identifiers.

If all we really care about is subtitles, we can skip this step and move
on to downloading subtitles. By default, this will proceed with
downloading English language subtitles, but you can customise this using
the dedicated function.

``` r
yt_get_subtitles_playlist(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
)
```

This will download all relevant subtitles and return a data frame with
some basic metadata about them.

The next step is to actually import these subtitles in a format that is
easy to parse in R. You can download and import them in a single go
with:

``` r
yt_get_subtitles_playlist(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
) |>
  yt_read_vtt()
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■ 86% | ETA: 0s
#> # A tibble: 8,547 × 5
#>    yt_id       language line_id text                                  start_time
#>    <chr>       <chr>      <int> <chr>                                 <chr>     
#>  1 YSfwPzWM-8o en             1 "foreign"                             00:00:01.…
#>  2 YSfwPzWM-8o en             2 ""                                    00:00:10.…
#>  3 YSfwPzWM-8o en             3 "systems engineering principles my n… 00:00:13.…
#>  4 YSfwPzWM-8o en             4 "is Robin bisbrook I work at Aztec i… 00:00:17.…
#>  5 YSfwPzWM-8o en             5 "concurrent design facility I starte… 00:00:19.…
#>  6 YSfwPzWM-8o en             6 "career in in France Guyana in 1997 … 00:00:24.…
#>  7 YSfwPzWM-8o en             7 "I've worked at several places at uh… 00:00:27.…
#>  8 YSfwPzWM-8o en             8 "the European Space Agency centers i… 00:00:29.…
#>  9 YSfwPzWM-8o en             9 "Germany and the Netherlands ever si… 00:00:31.…
#> 10 YSfwPzWM-8o en            10 "and I've had my own company as well… 00:00:35.…
#> # ℹ 8,537 more rows
```

Or, yf you want to parse only subtitles that are locally available, you
can achieve the same with `yt_get_local_subtitles()`:

``` r
subs_df <- yt_get_local_subtitles(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
) |>
  yt_read_vtt()
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■ 86% | ETA: 0s
```

So… these are lengthy video clips with hours of recordings by the
European Space Agency. Let’s see all the times when they mention the
word “rover”:

``` r
subs_df |>
  dplyr::select(-language, -line_id) |>
  dplyr::filter(stringr::str_detect(
    string = text,
    pattern = stringr::regex("rover", ignore_case = TRUE)
  ))
#> # A tibble: 11 × 3
#>    yt_id       text                                     start_time  
#>    <chr>       <chr>                                    <chr>       
#>  1 YSfwPzWM-8o lunar Rovers as you see in the bottom    00:00:46.549
#>  2 YSfwPzWM-8o aggressive Rover we may be in trouble    00:20:25.850
#>  3 M2awfGQIEoU Rover on the surface of Mars and being   00:03:24.050
#>  4 M2awfGQIEoU Roslyn Franklin Rover that I mentioned   00:10:15.230
#>  5 M2awfGQIEoU before the first Rover that can actually 00:10:16.910
#>  6 M2awfGQIEoU the Rover itself but on top of that for  00:10:24.889
#>  7 M2awfGQIEoU Roslyn Franklin Rover which is           00:11:32.210
#>  8 M2awfGQIEoU here's the Rover and there's exomar's    00:11:44.990
#>  9 M2awfGQIEoU perseverance Rover that's already been   00:11:55.730
#> 10 NpF75U10ewM into a strange place during microverity  00:04:17.569
#> 11 qlbBCymbdOM spacewalk which is a lect Rover that can 00:49:16.370
```
