## ----setup---------------------------------------------------------------
knitr::opts_chunk$set(warnings = F, message = F)

## ------------------------------------------------------------------------
if(!require('devtools')) install.packages('devtools')
devtools::install_github('jdossgollin/cpcRain', dependencies = T)
library(cpcRain)

## ---- eval=FALSE---------------------------------------------------------
#  vignette('Introduction', package = 'cpcRain')

## ------------------------------------------------------------------------
dt1 <- cpcQueryDateRange(start_date = ymd('1998-12-24'),
                         end_date = ymd('1999-01-04'),
                         tidy = T)

## ------------------------------------------------------------------------
dt1$download_success

## ------------------------------------------------------------------------
dt1$precip_data

## ------------------------------------------------------------------------
dt2 <- cpcQueryDateRange(start_date = ymd('1998-12-24'),
                         end_date = ymd('1999-01-04'),
                         tidy = F)

## ------------------------------------------------------------------------
dt2$precip_data %>% dim()

## ------------------------------------------------------------------------
lapply(dimnames(dt2$precip_data), head)

## ------------------------------------------------------------------------
dt3 <- dt2$precip_data %>% cpcMeltArray
colMeans(dt3 == dt1$precip_data, na.rm = T)

## ------------------------------------------------------------------------
download_years <- 1979:2016
success <- vector('list', length(download_years))
for(i in 1:length(download_years)){
  success[[i]] <- cpcYearToNCDF(
    year = download_years[i],
    download_folder = '~/Documents/Data/CPC/',
    empty_raw = TRUE,
    overwrite = FALSE
  )
}
success <- rbindlist(success)

## ------------------------------------------------------------------------
success[order(success, date)]

## ------------------------------------------------------------------------
nc <- nc_open("~/Documents/Data/CPC/cpcRain_1997.nc")

## ------------------------------------------------------------------------
nc$dim$time$vals[1:10]
nc$dim$time$units

## ---- warning=TRUE-------------------------------------------------------
dt4 <- cpcReadNCDF(
  start_date = ymd('1997-12-01'),
  end_date = ymd('1999-02-11'),
  lat_lims = c(35, 45),
  lon_lims = c(100, 110),
  download_folder = '~/Documents/Data/CPC/',
  tidy = TRUE,
  round_lonlat = TRUE
)
print(dt4)

