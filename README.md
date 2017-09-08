
Getting Started with cpcRain
[![Build Status](https://travis-ci.org/jdossgollin/cpcRain.svg?branch=master)](https://travis-ci.org/jdossgollin/cpcRain)
================
James Doss-Gollin
2016-06-28

``` r
knitr::opts_chunk$set(warnings = F, message = F)
```


Motivation
==========

This package is an extension and overhaul of the original [cpcRain package](https://github.com/dlebauer/cpcRain) by [dlebauer](https://github.com/dlebauer). Many of the functions were written by Gopi Goteti in their first form and I have just updated and extended them. That package presented R code to download and analyze global precipitation data from the Climate Prediction Center (CPC)

-   Spatial Coverage: Global (mostly land areas)
-   Temporal Coverage: 1979 - present
-   Spatial Resolution: 0.5 degrees lat-lon
-   Temporal Resolution: daily

Hydrological and climatological studies sometimes require rainfall data over the entire world for long periods of time. The Climate Prediction Center's [(CPC)](http://www.cpc.ncep.noaa.gov/) daily data, from 1979 to present, at a spatial resolution of 0.5 degrees lat-lon (~ 50 km at the equator) is a good resource. This data is available at CPC's ftp site (<ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/>). However, there are a number of issues:

Issues with obtaining data:

-   there are too many files (365/366 per year \* 34 years, separate folder for each year)
-   file naming conventions have chnaged over time, one format prior to 2006 and couple of different formats afterwards
-   downloading multiple files simultaneously from the CPC ftp site does not seem to work properly.

Issues with processing data:

-   file formats have changed over time, gzipped files prior to 2008 and binary files afterwards
-   files are in binary format and there no software/code readily available to process/plot the data.


Package Philosophy
==================

This package is designed to facilitate two use cases that are likely to cover most users of the CPC data:

1.  Users who wish to extract data from a single date or a short date range for one-time use. This is possible through the `cpcQueryDateRange` function.
2.  Users who wish to build a library of CPC data which they can query whenever is needed. This is accomplished by two functions. First the `cpcYearToNCDF` function downloads all CPC data (one year at a time) and stores the full year of data to a compressed NCDF (version 4) file. Next the `cpcReadNCDF` function allows users to easily extract data from those files. Extracting data from multiple years at once is permitted, as long as the data files for all years are present.

Further, this package supports users who wish to extract data in two formats:

 1. 3D arrays. The CPC data is gridded on a 0.5 degree grid of longitude and latitude; the third dimension is time. 
 2. Tidy data, via the `data.table` package. This format allows for easy manipulation of multiple variables, subsetting, grouping, and other fast operations on the data.


Installation
------------

``` r
if(!require('devtools')) install.packages('devtools')
devtools::install_github('jdossgollin/cpcRain', dependencies = T)
library(cpcRain)
```


Accessing This Document
-----------------------

You can read this vignette at any time from your **R** session by calling:

``` r
vignette('Introduction', package = 'cpcRain')
```


Example 1: Sending a Quick Data Query
=====================================

For this example, we'll download data from the winter holidays of 1998. Since we're just interested in a short date range, we don't need to download years of data, write `.nc` files, or construct complicated databases. We do this with the `cpcQueryDateRange` function:

``` r
dt1 <- cpcQueryDateRange(start_date = ymd('1998-12-24'),
                         end_date = ymd('1999-01-04'),
                         tidy = T)
```

We'll look into the `tidy` argument in a moment. The `cpcQueryDateRange` gives us a list of outputs. The first tells us whether the dates we requested were successfully downloaded:

``` r
dt1$download_success
```

    ##          date success
    ## 1  1998-12-24    TRUE
    ## 2  1998-12-25    TRUE
    ## 3  1998-12-26    TRUE
    ## 4  1998-12-27    TRUE
    ## 5  1998-12-28    TRUE
    ## 6  1998-12-29    TRUE
    ## 7  1998-12-30    TRUE
    ## 8  1998-12-31    TRUE
    ## 9  1999-01-01    TRUE
    ## 10 1999-01-02    TRUE
    ## 11 1999-01-03    TRUE
    ## 12 1999-01-04    TRUE

The second gives the rainfall data:

``` r
dt1$precip_data
```

    ##                date    lon    lat prcp_mm
    ##       1: 1998-12-24   0.25 -89.75       0
    ##       2: 1998-12-24   0.75 -89.75       0
    ##       3: 1998-12-24   1.25 -89.75       0
    ##       4: 1998-12-24   1.75 -89.75       0
    ##       5: 1998-12-24   2.25 -89.75       0
    ##      ---                                 
    ## 3110396: 1999-01-04 357.75  89.75      NA
    ## 3110397: 1999-01-04 358.25  89.75      NA
    ## 3110398: 1999-01-04 358.75  89.75      NA
    ## 3110399: 1999-01-04 359.25  89.75      NA
    ## 3110400: 1999-01-04 359.75  89.75      NA

Since we set `tidy = TRUE`, we get a tidy `data.table`. If you're not familiar with this package and data format, you should read their introductions (on the CRAN package page, for example). The `data.table` syntax allows us to subset, group, and apply functions to the data easily. We can also *cast* our data to create a matrix of dates versus grid cells using the `data.table::dcast` function.

We can also set `tidy = FALSE` to get an array of the data:

``` r
dt2 <- cpcQueryDateRange(start_date = ymd('1998-12-24'),
                         end_date = ymd('1999-01-04'),
                         tidy = F)
```

Be aware that every time you use the `cpcQueryDateRange` function, data is re-downloaded from the server.

``` r
dt2$precip_data %>% dim()
```

    ## [1] 720 360  12

As expected, our data has 720 values of longitude, 360 of latitude, and 12 of time. The `dimnames` gives us the longitude, latitude, and date parameters in an easy-to-parse format:

``` r
lapply(dimnames(dt2$precip_data), head)
```

    ## [[1]]
    ## [1] "0.25" "0.75" "1.25" "1.75" "2.25" "2.75"
    ## 
    ## [[2]]
    ## [1] "-89.75" "-89.25" "-88.75" "-88.25" "-87.75" "-87.25"
    ## 
    ## [[3]]
    ## [1] "1998-12-24" "1998-12-25" "1998-12-26" "1998-12-27" "1998-12-28"
    ## [6] "1998-12-29"

If we want, we can use the `cpcMeltArray` function to turn the 3D array of `dt2$precip_data` into the `data.table` of `dt1$precip_data`:

``` r
dt3 <- dt2$precip_data %>% cpcMeltArray
colMeans(dt3 == dt1$precip_data, na.rm = T)
```

    ##    date     lon     lat prcp_mm 
    ##       1       1       1       1

This shows that we get the same results either way.


Example 2: Building a Data Library
==================================

Now let's imagine that we're not content just querying data from a few weeks, but we want to look at all rainfall over the Northeast United States from 1997-2000. Since this will be a large data set, we're going to use the `cpcYearToNCDF` function to build a library of `.nc` files, one for each year, to store our data. That way, we can access it efficiently whenever we want.

``` r
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
```

The `download_folder` parameter specifies where we want to save our `.nc` files after we create them. The `empty_raw` is set to TRUE, so the program will automatically delete the raw files downloaded from the CPC server after the `.nc` file is successfully created. Finally, the `overwrite` parameter is FALSE, so for a given year if the `.nc` file already exists then the function won't download the data and write the data.

We can check the success of the data download:

``` r
success[order(success, date)]
```

    ##              date       success
    ##     1: 1979-01-01 Not Attempted
    ##     2: 1979-01-02 Not Attempted
    ##     3: 1979-01-03 Not Attempted
    ##     4: 1979-01-04 Not Attempted
    ##     5: 1979-01-05 Not Attempted
    ##    ---                         
    ## 13876: 2016-12-27 Not Attempted
    ## 13877: 2016-12-28 Not Attempted
    ## 13878: 2016-12-29 Not Attempted
    ## 13879: 2016-12-30 Not Attempted
    ## 13880: 2016-12-31 Not Attempted

If it shows up as "Not Attempted", it's because the `.nc` file was already downloaded and `overwrite` was set to FALSE. The process of downloading the files and creating the `.nc` files is slow, but once they're there, it's very easy to query them. You don't even need to do it from **R** -- any software package that can read NCDF *version 4* files can read them. One way to read the files is with the excellent `ncdf4` package like:

``` r
nc <- nc_open("~/Documents/Data/CPC/cpcRain_1997.nc")
```

You'll notice that the units on the `time` variable are a bit odd:

``` r
nc$dim$time$vals[1:10]
```

    ##  [1] 9862 9863 9864 9865 9866 9867 9868 9869 9870 9871

``` r
nc$dim$time$units
```

    ## [1] "days since 1970-01-01"

However, the advantage here is that the `lubridate` package's `as_date` function takes the origin to be 1970-01-01 by default, so you can call `as_date(nc$dim$time$vals)` without any trouble.

Still, this is a needlessly complicated way to extract data from these files. You don't even have to call . The much easier way is to use the `cpcReadNCDF` function, which can extract data from multiple years at once. Since the `.nc` files are gridded by default, we can subset the data before reading it in:

``` r
dt4 <- cpcReadNCDF(
  start_date = ymd('1997-12-01'),
  end_date = ymd('1999-02-11'),
  lat_lims = c(35, 45),
  lon_lims = c(100, 110),
  download_folder = '~/Documents/Data/CPC/',
  tidy = TRUE,
  round_lonlat = TRUE
)
```

    ## Warning in cpcReadNCDF(start_date = ymd("1997-12-01"), end_date =
    ## ymd("1999-02-11"), : Adjusting lat_lims to nearest grid point
    
    ## Warning in cpcReadNCDF(start_date = ymd("1997-12-01"), end_date =
    ## ymd("1999-02-11"), : Adjusting lon_lims to nearest grid point

``` r
print(dt4)
```

    ##               date    lon   lat    prcp_mm
    ##      1: 1997-12-01  99.75 34.75 0.87346697
    ##      2: 1997-12-01 100.25 34.75 0.65020645
    ##      3: 1997-12-01 100.75 34.75 0.40431538
    ##      4: 1997-12-01 101.25 34.75 0.20078394
    ##      5: 1997-12-01 101.75 34.75 0.07473714
    ##     ---                                   
    ## 193154: 1999-02-11 107.75 44.75 0.00000000
    ## 193155: 1999-02-11 108.25 44.75 0.00000000
    ## 193156: 1999-02-11 108.75 44.75 0.00000000
    ## 193157: 1999-02-11 109.25 44.75 0.00000000
    ## 193158: 1999-02-11 109.75 44.75 0.00000000

The `start_date`, `end_date`, `lat_lims`, and `lon_lims` parameters are pretty straightforward and do exactly what you would imagine. The `download_folder` needs to be where the `.nc` files are stored -- this will be the same as the argument to the `cpcYearToNCDF` function. The `tidy` argument, like before, causes the function to return a `data.table` if TRUE and a 3D array if FALSE. The array can, again, be melted with `cpcMeltArray`. Finally, the `round_lonlat` argument is set to TRUE. Under the hood, the function automatically rounded the `lat_lims` and `lon_lims` slightly to give results that fit within the data. If `round_lonlat` is FALSE, then entering values that aren't in the data set will throw an error.


Improvements
============

This is a brand new version of this package, so there are likely to be bugs. Please use the issues tracker at <https://github.com/jdossgollin/cpcRain/issues> to report issues, bugs, improvements, bad documentation, etc. Thanks in advance for your help!
