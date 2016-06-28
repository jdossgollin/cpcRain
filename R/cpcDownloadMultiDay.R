#' Download a Date Range from the CPC FTP Server
#'
#' This function is not intended to be called directly.
#' It downloads a date range from the CPC FTP server by using cpcDownloadOneDay inside of a try statement.
#' Any dates that are not successfully downloaded are tried a second time.
#' @param start_date first date to download; must be a date object
#' @param end_date last date to download; must be a date object
#' @param download_folder the folder to which to download the files. Defaults to \code{getwd()}
#' @param overwrite if TRUE, will overwrite any file with the same name in the \code{download_folder}.
#'   If FALSE, will not overwrite any file -- if a file with the same name already exists, will
#'   not download again.
#' @return returns a \code{data.frame} with columns date and success. The success column indicates whether
#'   the raw file for that date was successfully downloaded.
#' @export cpcDownloadMultiDay
#' @import magrittr
cpcDownloadMultiDay <- function(start_date, end_date, download_folder = getwd(), overwrite = F){

  require(lubridate)
  require(magrittr)

  if(!lubridate::is.Date(start_date) | !lubridate::is.Date(end_date))
    stop('date must be a R date object.See lubridate package for an easy way to accomplish this.')
  if(!(year(start_date) %in% 1979:year(Sys.Date()) & year(end_date) %in% 1979:year(Sys.Date())))
    stop('data range must be from 1979 to present')

  if(!dir.exists(download_folder)) stop('invalid download folder')

  all_dates <- seq(start_date, end_date, 1)
  success_vec <- rep(NA, length(all_dates))

  for(i in 1:length(all_dates)){

    date_i <- all_dates[i]
    success_vec[i] <- try(cpcDownloadOneDay(date_i,
                                       download_folder =
                                         download_folder,
                                       overwrite = overwrite),
                     silent = TRUE)

  }

  # if there were any dates that gave errors, try them again one more time.
  dates_to_retry <- which(success_vec != "TRUE")
  for(date_i in dates_to_retry){

    date_i <- all_dates[i]
    success_vec[i] <- try(cpcDownloadOneDay(date_i,
                                            download_folder =
                                              download_folder,
                                            overwrite = overwrite),
                          silent = TRUE)

  }

  # convert success_vec to logical
  success_vec <- success_vec == 'TRUE'

  # done
  return(data.frame(date = all_dates, success = success_vec))

}
