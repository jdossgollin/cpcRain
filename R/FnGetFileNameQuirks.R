#' Identify filename quirks for each year
#'
#' This function returns the filename quirks for each year from the CPC data set.
#' This function is not intended to be called directly.
#' @param yr the year for which data is being downloaded
#' @return returns a list of urlTag and fileTag
#' @export cpcGetFileNameQuirks
#' @author Gopi Goteti
#' @author James Doss-Gollin
cpcGetFileNameQuirks <- function(yr) {
  
  require(lubridate)

  if (yr %in% seq(1979, 2005)) {

    urlTag  <- "V1.0/"
    fileTag <- ".gz"

  } else if (yr %in% c(2006)) {

    urlTag  <- "RT/"
    fileTag <- "RT.gz"

  } else if (yr %in% c(2007, 2008)) {

    urlTag  <- "RT/"
    fileTag <- ".RT.gz"

  } else if (yr %in% seq(2009, year(Sys.Date()))) {

    urlTag  <- "RT/"
    fileTag <- ".RT"

  } else {

    stop("year out of bounds! check!")

  }

  return(list(
    urlTag = urlTag,
    fileTag = fileTag
  ))
}
