#' Access CPC Data for a Short Date Range
#'
#' This function provides access to CPC data for a date range.
#' This function is intended to be called directly.
#' For each date in the date range, it downloads the raw files, reads them to an array,
#' and deletes the raw files.
#' By default it returns a tidy data.table, but it can also return a 3D array.
#' @param start_date the first data to download. Must be a date object -- see \code{lubridate} package for easy creation of date objects
#'   with the \code{lubridate::ymd()} function.
#' @param end_date as with \code{start_date}, must be a date object.
#' @param tidy if TRUE, the output data will be a tidy data.table with columns lon, lat, and prcp_mm.
#'   if FALSE, the output data will be a 3D array with indices [lon, lat, time]
#' @return returns a list with two entries: download_success and precip_data.
#'   download_success is a data.frame with columns date and success, which define whether data was successfully downloaded for
#'   each date in the range \code{seq(start_date, end_date, 1)}.
#'   precip_data is a 3D array if tidy is FALSE and a data.table if tidy is TRUE.
#' @import data.table
#' @import magrittr
#' @export cpcQueryDateRange
cpcQueryDateRange <- function(start_date, end_date, tidy = TRUE){

  require(lubridate)

  if(!lubridate::is.Date(start_date) | !lubridate::is.Date(end_date))
    stop('date must be a R date object.See lubridate package for an easy way to accomplish this.')
  if(!(year(start_date) %in% 1979:year(Sys.Date()) & year(end_date) %in% 1979:year(Sys.Date())))
    stop('data range must be from 1979 to present')

  # global values
  param <- cpcGlobal()

  # create a folder to download temporary data in
  download_folder <- paste0(getwd(), '/tmp_cpc_folder')
  dir.create(download_folder)

  # all dates
  all_dates <- seq(start_date, end_date, 1)

  # track which days were successfully downloaded
  all_date_success <- rep(NA, length(all_dates))

  # Download the Raw Data
  for(i in 1:length(all_dates)){

    date_i <- all_dates[i]
    all_date_success[i] <- cpcDownloadOneDay(date = date_i, download_folder = download_folder)

  }

  download_success_df <- data.frame(date = all_dates, success = all_date_success)


  # Read in the Data

  # first initialize array
  lons <- param$cpcLonVec
  lats <- param$cpcLatVec
  times <- as.character(seq(start_date, end_date, 1))
  array <- array(dim = c(length(lons), length(lats), length(times)),
                 dimnames = list(lons, lats, times))
  # accessed by [lat, lon, time]

  # For each day of the year: (1) download raw file (2) read raw file (3) save to memory
  for(i in 1:length(all_dates)){

    date_i <- all_dates[i]
    array[, , i] <- cpcReadRawOneDay(date = date_i, download_folder = download_folder)
  }

  unlink(download_folder, recursive = T, force = T)



  # return download success and the output
  out <- list(download_success = download_success_df)

  # if tidy data option is true, melt the array
  if(tidy){
    out$precip_data <- cpcMeltArray(array)
  } else {
    out$precip_data <- array
  }

  return(out)

}
