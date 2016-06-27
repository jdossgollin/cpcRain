#' Download CPC Data for a Single Day
#'
#' This function returns CPC precipitation data for a single date.
#' Since the server can be a bit touchy, will try up to five times to connect to the server and
#'   download the data.
#' @title Download a single CPC data file
#' @param date \strong{R} date object
#' @param download_folder the directory to which you want to download the raw files. Defaults to current directory.
#' @param overwrite if TRUE, will overwrite an existing file in the directory. If FALSE and a file with the same name exists,
#'   will download anything, but return successful.
#' @return returns TRUE if the data was downloaded successfully and FALSE otherwise
#' @export cpcDownloadOneDay
#' @author Gopi Goteti
#' @author James Doss-Gollin

cpcDownloadOneDay <- function(date, download_folder = getwd(), overwrite = FALSE) {

  require(lubridate)

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

  # url and file prefixes
  urlHead  <- "ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/"
  fileHead <- "PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx."

  # identify the file name quirks for each year
  quirks <- cpcGetFileNameQuirks(yr)

  # date in the format yyyy-mm-dd
  dateLong <- as.Date(paste(yr, mo, day, sep="-"))

  # date string used in the filenames below
  dateStr  <- paste0(substr(dateLong, 1, 4),
                     substr(dateLong, 6, 7),
                     substr(dateLong, 9, 10))

  # construct url
  fileUrl <- paste0(urlHead,
                    quirks$urlTag,
                    yr,
                    "/",
                    fileHead,
                    dateStr,
                    quirks$fileTag)

  # out file name; gzipped file prior to 2008 otherwise binary
  outFile <- ifelse(yr <= 2008,
                    paste0(download_folder, "raw_", dateStr, ".gz"),
                    paste0(download_folder, "raw_", dateStr, ".bin"))

  # download

  if(overwrite | !file.exists(outFile)){

    file_success <- FALSE
    n_tries <- 0

    while(!file_success & n_tries <= 5) {
      file_success <- try(
        if (yr <= 2008) {
          download.file(url=fileUrl, destfile=outFile)
        } else {
          download.file(url=fileUrl, destfile=outFile, mode="wb")
        }
      )
      file_success <- as.logical(1 - file_success)
      n_tries <- n_tries + 1
    }
  } else {
    file_success <- TRUE
  }


  return(file_success)

}
