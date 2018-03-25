#' Identify filename quirks for each year
#'
#' This function returns the filename quirks for each year from the CPC data set.
#' This function is not intended to be called directly.
#' @param yr the year for which data is being downloaded
#' @return returns a list of urlTag and fileTag
#' @export cpcGetFileNameQuirks
#' @author Gopi Goteti
#' @author James Doss-Gollin
#' @details the URL for the individual files is not exactly the same and changes from
#'   CPC's retrospective analyses (< 2006) to real-time analyses (> 2006)
#'   below are example URLs, xxx = ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB
#'   xxx/V1.0/1979/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.19790101.gz
#'   xxx/RT/2006/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.20060101RT.gz
#'   xxx/RT/2007/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.20070101.RT.gz
#'   xxx/RT/2009/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.20090101.RT
cpcGetFileNameQuirks <- function(yr) {

  if (yr %in% seq(1979, 2005)) {

    urlTag  <- "V1.0/"
    fileTag <- ".gz"

  } else if (yr %in% c(2006)) {

    urlTag  <- "RT/"
    fileTag <- "RT.gz"

  } else if (yr %in% c(2007, 2008)) {

    urlTag  <- "RT/"
    fileTag <- ".RT.gz"

  } else if (yr %in% seq(2009, 2018)) {

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
