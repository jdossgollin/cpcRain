#' Global Values for the CPC Data Set
#'
#' This function is not intended to be called directly.
#' Returns a list which contains several parameters useful for other functions so that
#' they can be saved in a single location.
#' @export cpcGlobal
#' @author James Doss-Gollin

cpcGlobal <- function(){
  glob <- list()

  # CPC data dimensions, from PRCP_CU_GAUGE_V1.0GLB_0.50deg_README.txt
  glob$cpcNumLat   <- 360 # number of lats
  glob$cpcNumLon   <- 720 # number of lons
  glob$cpcNumBytes <- glob$cpcNumLat * glob$cpcNumLon * 2 # 2 fields, precipitation and num gages
  glob$cpcRes      <- 0.5 # data resolution
  glob$cpcLatVec   <- -89.75 + (1:glob$cpcNumLat)*glob$cpcRes - glob$cpcRes # latitudes
  glob$cpcLonVec   <- 0.25 + (1:glob$cpcNumLon)*glob$cpcRes - glob$cpcRes # longitudes

  return(glob)
}
