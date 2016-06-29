#' Build a NCDF File from CPC Data
#'
#' This function builds a NCDF (.nc) file from CPC data for a single year.
#' To do this it downloads raw data from the CPC ftp server, reads it to an array, and writes that array to
#' a NCDF file.
#' It will always build the file for all data for that particular year.
#' @param year the year for which to download. Must be an integer.
#' @param download_folder the folder in which to store the .nc file. Defaults to \code{getwd()}.
#' @param empty_raw if TRUE, will delete the raw data. Defaults to TRUE
#' @param overwrite if TRUE, will proceed even if a `.nc` file for the specified year exists. If FALSE, will not run.
#' @import data.table
#' @import magrittr
#' @export cpcYearToNCDF
#' @return a data.table with columns date and success

cpcYearToNCDF <- function(year, download_folder = getwd(), empty_raw = TRUE, overwrite = F){

  require(lubridate)

  # check for valid year
  if(!(year %in% 1979:(lubridate::year(Sys.Date())))) stop('invalid year')

  # check download_folder validity
  if(substr(download_folder, nchar(download_folder), nchar(download_folder)) != '/') download_folder <- paste0(download_folder, '/')
  if(!dir.exists(download_folder)) stop('invalid download_folder specified')

  # global values
  param <- cpcGlobal()



  # For each day of the year: (1) download raw file (2) read raw file (3) save to memory


  # define name of nc variable
  nc_filename <- paste0(download_folder, 'cpcRain_', year, '.nc')

  if(!file.exists(nc_filename) | overwrite){
    # first initialize array
    lons <- param$cpcLonVec
    lats <- param$cpcLatVec
    times <- as.numeric(seq(lubridate::ymd(paste(year, 1, 1)), lubridate::ymd(paste(year, 12, 31)), 1))
    array <- array(dim = c(length(lons), length(lats), length(times)),
                   dimnames = list(lons, lats, times))
    # [lat, lon, time]


    # create temp folder for raw data
    tmp_folder <- paste0(download_folder, 'temp_', year)
    dir.create(tmp_folder)

    # load the data in
    download_success_df <- cpcDownloadMultiDay(
      start_date = lubridate::ymd(paste(year, 1, 1)),
      end_date = lubridate::ymd(paste(year, 12, 31)),
      download_folder = tmp_folder,
      overwrite = F) %>% data.table()

    # loop through to fill the 3D array
    for(i in 1:length(times)){
      date_i <- as_date(times[i])
      array[, , i] <- cpcReadRawOneDay(date = date_i, download_folder = tmp_folder)
    }

    # define dimensions of the data array for ncdf saving
    nc_lats <- ncdf4::ncdim_def("lat", "degrees N", lats)
    nc_lons <- ncdf4::ncdim_def("lon", "degrees E", lons)
    nc_times <- ncdf4::ncdim_def("time", "days since 1970-01-01", as.numeric(times), unlim = TRUE)

    # define a variable for ncdf
    precip_ncvar <- ncdf4::ncvar_def(
      name = 'precip',
      units = 'mm',
      dim = list(nc_lons, nc_lats, nc_times),
      missval = NA,
      longname = 'daily gridded precipitation, in mm',
      verbose = F,
      compression = 5 # make the file smaller
    )

    # all days to download
    times_ymd <- as_date(times)


    # ----------------- write to NCDF File --------

    # create file connection
    nc <- ncdf4::nc_create(filename = nc_filename, vars = precip_ncvar)

    # loop through, adding 2D slices, because time is an unlimited dimension
    for( i in 1:length(times)) {

      ncdf4::ncvar_put(nc,
                varid = precip_ncvar,
                vals = array[, , i],
                start = c(1, 1, i),
                count = c(-1, -1, 1)
      )

    }

    # close file connection
    ncdf4::nc_close(nc)

    # delete the temp folder, if desired
    if(empty_raw) unlink(tmp_folder, recursive = T, force = T)

  } else {

    download_success_df <- data.table(date = seq(ymd(paste(year, 1, 1)), ymd(paste(year, 12, 31)), 1),
                                      success = "Not Attempted")

  }


  return(download_success_df)

}
