
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ytdlpr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

`ytdlpr` wraps some functionalities of `yt-dlp` to facilitate their use
in R-based workflows. It is currently focused on retrieving and parsing
subtitles, but can also download the video files, and trim them in order
to include only the part of the video clip where a given subtitle line
has been spoken.

It assumes you have [`yt-dlp`](https://github.com/yt-dlp/yt-dlp)
installed and the only useful function that works without having
`yt-dlp` installed is `yt_read_vtt()`, useful for importing into R
subtitles files. If you want to use `yt_trim()` to trim video files, you
will need to have [`ffmpeg`](https://ffmpeg.org/) installed.

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
downloading English sub_lang subtitles, but you can customise this using
the dedicated function.

``` r
yt_get(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P",
  subtitles = TRUE
)
```

This will download all relevant subtitles and return a data frame with
some basic metadata about them.

The next step is to actually import these subtitles in a format that is
easy to parse in R. You can download and import them in a single go
with:

``` r
yt_get(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P",
  subtitles = TRUE
) |>
  yt_read_vtt()
#> # A tibble: 58,960 × 5
#>    yt_id       sub_lang     line_id text                              start_time
#>    <chr>       <chr>          <int> <chr>                             <chr>     
#>  1 -0pPBAiJaYk Language: en       1 and in doing so we identified a … 00:00:07.…
#>  2 -0pPBAiJaYk Language: en       2 and in doing so we identified a … 00:00:07.…
#>  3 -0pPBAiJaYk Language: en       3 key                               00:00:08.…
#>  4 -0pPBAiJaYk Language: en       4 elements firstly we were repeati… 00:00:10.…
#>  5 -0pPBAiJaYk Language: en       5 same ggplot theme elements withi… 00:00:13.…
#>  6 -0pPBAiJaYk Language: en       6 and across multiple different fi… 00:00:15.…
#>  7 -0pPBAiJaYk Language: en       7 meaning we were copying code chu… 00:00:17.…
#>  8 -0pPBAiJaYk Language: en       8 every single time we were creati… 00:00:18.…
#>  9 -0pPBAiJaYk Language: en       9 script and new plot um important… 00:00:21.…
#> 10 -0pPBAiJaYk Language: en      10 wasn't standard across the board… 00:00:23.…
#> # ℹ 58,950 more rows
```

Or, yf you want to parse only subtitles that are locally available, you
can achieve the same with `yt_get_local_subtitles()`:

``` r
subtitles_df <- yt_get_local_subtitles(
  playlist = "https://www.youtube.com/playlist?list=PLbyvawxScNbuSi7sJaJbHNyyx3iYJeW3P"
) |>
  yt_read_vtt()
```

So… these are lengthy video clips with hours of recordings by the
European Space Agency. Let’s see all the times when they mention the
word “rover”:

``` r
rover_df <- yt_filter(
  pattern = "rover",
  subtitles_df = subtitles_df
)
rover_df
#> # A tibble: 11 × 6
#>    yt_id       sub_lang     line_id text                        start_time link 
#>    <chr>       <chr>          <int> <chr>                       <chr>      <chr>
#>  1 YSfwPzWM-8o Language: en      14 lunar Rovers as you see in… 00:00:46.… http…
#>  2 YSfwPzWM-8o Language: en     495 aggressive Rover we may be… 00:20:25.… http…
#>  3 M2awfGQIEoU Language: en      82 Rover on the surface of Ma… 00:03:24.… http…
#>  4 M2awfGQIEoU Language: en     255 Roslyn Franklin Rover that… 00:10:15.… http…
#>  5 M2awfGQIEoU Language: en     256 before the first Rover tha… 00:10:16.… http…
#>  6 M2awfGQIEoU Language: en     259 the Rover itself but on to… 00:10:24.… http…
#>  7 M2awfGQIEoU Language: en     287 Roslyn Franklin Rover whic… 00:11:32.… http…
#>  8 M2awfGQIEoU Language: en     292 here's the Rover and there… 00:11:44.… http…
#>  9 M2awfGQIEoU Language: en     297 perseverance Rover that's … 00:11:55.… http…
#> 10 NpF75U10ewM Language: en      97 into a strange place durin… 00:04:17.… http…
#> 11 qlbBCymbdOM Language: en    1074 spacewalk which is a lect … 00:49:16.… http…
```

The resulting data frame includes a direct link to the relevant video
clip at the exact timing. Here just a few examples, with just one
mention to `rover` per clip.

- <https://youtu.be/M2awfGQIEoU?t=612>
- <https://youtu.be/NpF75U10ewM?t=255>
- <https://youtu.be/YSfwPzWM-8o?t=44>
- <https://youtu.be/qlbBCymbdOM?t=2953>

Let’s try again, with an example that may be more relevant and perhaps
more inspiring for possible use cases among R users: all references to
“community” in the playlist of Posit Conf 2023:

``` r
positconf2023_df <- yt_get(
  playlist = "https://www.youtube.com/playlist?list=PL9HYL-VRX0oRFZslRGHwHuwea7SvAATHp",
  subtitles = TRUE
) |>
  yt_read_vtt()

community_df <- yt_filter(
  pattern = "community",
  subtitles_df = positconf2023_df
)
community_df
#> # A tibble: 201 × 6
#>    yt_id       sub_lang     line_id text                        start_time link 
#>    <chr>       <chr>          <int> <chr>                       <chr>      <chr>
#>  1 -0pPBAiJaYk Language: en     306 team it's created a commun… 00:11:15.… http…
#>  2 18vfcf46ozE Language: en     322 American Community survey … 00:12:39.… http…
#>  3 18vfcf46ozE Language: en     396 is on community             00:15:22.… http…
#>  4 18vfcf46ozE Language: en     407 community so as our users … 00:15:44.… http…
#>  5 18vfcf46ozE Language: en     411 community and so me now as… 00:15:53.… http…
#>  6 18vfcf46ozE Language: en     414 appreciation for that comm… 00:16:00.… http…
#>  7 -0pPBAiJaYk Language: en     306 team it's created a commun… 00:11:15.… http…
#>  8 18vfcf46ozE Language: en     322 American Community survey … 00:12:39.… http…
#>  9 18vfcf46ozE Language: en     396 is on community             00:15:22.… http…
#> 10 18vfcf46ozE Language: en     407 community so as our users … 00:15:44.… http…
#> # ℹ 191 more rows
```

Here just a random sample of examples:

- <https://youtu.be/zCxT6fExFjY?t=958>
- <https://youtu.be/ncDEqHxMWnE?t=536>
- <https://youtu.be/ZCEadMMY6mE?t=264>
- <https://youtu.be/hfqjyeA_z7s?t=1088>
- <https://youtu.be/awTzbYXTlSc?t=141>
- <https://youtu.be/EihuM4oyOvs?t=1035>

## Retrieve subtitles starting from single video urls/id

At the most basic, if you just want to download a single video rather
than a whole playlist, there is not much of a difference, you just pass
the `yt_id` argument instead of `playlist`. Notice that `yt_id` accepts
both YouTube identifiers (the 11-character string mostly at the end of
YouTube links) as well as full URLs to a single video clip.

``` r
yt_get(
  yt_id = "https://youtu.be/WXPBOfRtXQE",
  subtitles = TRUE,
  video = TRUE,
  description = TRUE,
  info_json = TRUE
)
#> # A tibble: 1 × 6
#>   yt_id       sub_lang sub_format title       playlist path                     
#>   <chr>       <chr>    <chr>      <chr>       <chr>    <fs::path>               
#> 1 WXPBOfRtXQE en       vtt        This is ESA ""       …ESA [WXPBOfRtXQE].en.vtt
```

## Extracting only the relevant part of a video clip

Let’s say we want to export all mentions of a given word, downloading
the original video files, trimming them, and re-exporting them. This
would typicall start from a filtered set of subtitles, such as the one
created above. We’ll just keep the first two clips here, but of course
there is no inherent limit.

``` r
trim_community_df <- community_df |>
  dplyr::slice_head(n = 2)

trim_community_df
#> # A tibble: 2 × 6
#>   yt_id       sub_lang     line_id text                         start_time link 
#>   <chr>       <chr>          <int> <chr>                        <chr>      <chr>
#> 1 -0pPBAiJaYk Language: en     306 team it's created a communi… 00:11:15.… http…
#> 2 18vfcf46ozE Language: en     322 American Community survey d… 00:12:39.… http…
```

We would want to make sure that the relevant video clips have been
previously downloaded.

``` r
yt_get(
  yt_id = trim_community_df[["yt_id"]],
  video = TRUE,
  check_previous = TRUE # but set to FALSE, if you downloaded previously subtitles but not the video
)
#> # A tibble: 6 × 2
#>   yt_id       path                                                              
#>   <chr>       <fs::path>                                                        
#> 1 -0pPBAiJaYk …hemes on Top of ggplot - posit：：conf(2023) [-0pPBAiJaYk].en.vtt
#> 2 -0pPBAiJaYk …f Themes on Top of ggplot - posit：：conf(2023) [-0pPBAiJaYk].mkv
#> 3 18vfcf46ozE …ding to GitHub Issues) - posit：：conf(2023) [18vfcf46ozE].en.vtt
#> 4 18vfcf46ozE …ponding to GitHub Issues) - posit：：conf(2023) [18vfcf46ozE].mkv
#> 5 -0pPBAiJaYk …hemes on Top of ggplot - posit：：conf(2023) [-0pPBAiJaYk].en.vtt
#> 6 18vfcf46ozE …ding to GitHub Issues) - posit：：conf(2023) [18vfcf46ozE].en.vtt
```

And then the following would take those files, and extract only the
relevant part using `ffmpeg`. You’ll find the trimmed video clips in a
`0_trimmed_video` folder, along with other subtitles files.

``` r
yt_trim(subtitles_df = trim_community_df,
        simulate = TRUE)
#> # A tibble: 2 × 9
#>   yt_id       start_time   path                start_time_period end_time_period
#>   <chr>       <chr>        <fs::path>          <Period>          <Period>       
#> 1 -0pPBAiJaYk 00:11:15.670 … [-0pPBAiJaYk].mkv 11M 12.67S        11M 18.67S     
#> 2 18vfcf46ozE 00:12:39.710 … [18vfcf46ozE].mkv 12M 36.71S        12M 42.71S     
#> # ℹ 4 more variables: start_time_string <chr>, end_time_string <chr>,
#> #   destination_file <fs::path>, ffmpeg_command <chr>
```

## License and disclaimers.

This package is released with a MIT license. Much of what it does
requires external pacakges (in particular,
[yt-dlp](https://github.com/yt-dlp/yt-dlp) and
[ffmpeg](https://ffmpeg.org/): see their repositories for further
license details and disclaimers.
