#' Convert a CPC Array to a tidy data.table
#'
#' This function takes in an array with indices [lon, lat, time] and with dimnames giving the values and converts
#' the array to a data.table.
#' @param array the array to be converted to a tidy data.table
#' @import data.table
#' @import magrittr
#' @export cpcMeltArray
#' @return returns a data.table with columns date, lon, lat, and prcp_mm.
#'   The prcp_mm colum will have NA values, corresponding to areas over ocean.
#'   These can be easily eliminated with \code{na.omit()}.
cpcMeltArray <- function(array){
  require(data.table)
  require(lubridate)
  require(magrittr)

  lons <- dimnames(array)[[1]]
  lats <- dimnames(array)[[2]]
  times <- dimnames(array)[[3]] %>% lubridate::as_date()

  dt_list <- vector('list', length(times))
  for(i in 1:length(times)){
    dt_i <- array[, , i] %>% data.table::as.data.table()
    dt_i[, lon := lons]
    dt_list[[i]] <- dt_i %>% melt(id.var = 'lon', variable.name = 'lat', value.name = 'prcp_mm')
    dt_list[[i]][, lat := as.numeric(levels(lat))[lat]][, lon := as.numeric(lon)][, date := times[i]]
    dt_list[[i]] <- dt_list[[i]][, .(date, lon, lat, prcp_mm)]
  }
  dt_list <- rbindlist(dt_list)

  return(dt_list)
}
