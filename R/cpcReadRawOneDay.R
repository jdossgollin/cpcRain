#' Read Read Data from the CPC
#'
#' This function is not intended to be called directly.
#' It reads data from a raw file downloaded directly from the CPC ftp server and
#' returns a matrix with dimensions [lon, lat].
#' Since each raw file corresponds to data from a single date, there is no date dimension.
#' @param date the date corresponding to the file to read
#' @param download_folder the folder containing the files
#' @return returns a matrix with indices [lon, lat]. Values are daily rainfall, in mm.
#' @export cpcReadRawOneDay
#' @author Gopi Goteti
#' @author James Doss-Gollin
cpcReadRawOneDay <- function(date, download_folder = getwd()) {

  require(lubridate)
  require(ncdf4)

  if(!lubridate::is.Date(date)) stop('date must be a R date object.
                                     See lubridate package for an easy way to accomplish this.')

  # convert date to year, month, date
  yr <- year(date)
  mo <- month(date)
  day <- day(date)

  # check year validity
  if(!yr %in% 1976:year(Sys.Date())) stop('Year must be from 1976 to Present')

  # check download_folder validity
  if(substr(download_folder, nchar(download_folder), nchar(download_folder)) != '/') download_folder <- paste0(download_folder, '/')
  if(!dir.exists(download_folder)) stop('invalid download_folder specified')

  # file name
  dateStr <- paste0(yr, sprintf("%.2d", mo), sprintf("%.2d", day))
  if (yr <= 2008) {
    cpcFile <- paste0(download_folder, "raw_", dateStr, ".gz")
  } else {
    cpcFile <- paste0(download_folder, "raw_", dateStr, ".bin")
  }
  stopifnot(file.exists(cpcFile))

  # global params
  param <- cpcGlobal()

  # open file connection
  if (yr <= 2008) {
    fileCon <- gzcon(file(cpcFile, "rb"))
  } else {
    fileCon <- file(cpcFile, "rb")
  }

  # read data
  inData  <- readBin(con = fileCon,
                     what = numeric(),
                     n = param$cpcNumBytes,
                     size = 4,
                     endian = "little")
  close(fileCon)

  # extract precipitation (first field), ignore second field (num gages)
  inData <- inData[1:(param$cpcNumBytes/2)]

  # reshape, flip rows for proper North-South orientation
  # original data goes from South to North
  prcp_data <- array(0, dim=c(param$cpcNumLat, param$cpcNumLon))
  for(eachRow in 1:param$cpcNumLat) {
    index1 <- 1 + (eachRow-1) * param$ cpcNumLon
    index2 <- eachRow * param$cpcNumLon
    prcp_data[eachRow, ] <- inData[index1:index2]
  }

  # remove (missing) values
  prcp_data[prcp_data < 0] <- NA

  # convert tenths of mm to mm
  prcp_data <- ifelse(prcp_data > 0, prcp_data*0.1, prcp_data)

  # set dim names
  dimnames(prcp_data)[[1]] <- param$cpcLatVec
  dimnames(prcp_data)[[2]] <- param$cpcLonVec

  # transpose it
  prcp_data <- t(prcp_data)

  return (prcp_data)
}
