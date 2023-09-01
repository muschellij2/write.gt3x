
<!-- README.md is generated from README.Rmd. Please edit that file -->

# write.gt3x

<!-- badges: start -->

[![R-CMD-check](https://github.com/muschellij2/write.gt3x/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/muschellij2/write.gt3x/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `write.gt3x` is to convert accelerometry into Actigraph GT3X
file formats.

## Installation

You can install the development version of `write.gt3x` like so:

``` r
remotes::install_github("muschellij2/write.gt3x")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(write.gt3x)
if (requireNamespace("read.gt3x", quietly = TRUE)) {
  gt3xfile <- system.file(
    "extdata", "TAS1H30182785_2019-09-17.gt3x",
    package = "read.gt3x")
  df <- read.gt3x::read.gt3x(
    gt3xfile, imputeZeroes = FALSE, asDataFrame = TRUE,
    verbose = TRUE)
  sample_rate = attr(df, "sample_rate")
  max_g = attr(df, "acceleration_max")
  max_g = as.character(as.integer(max_g))
  out = write_gt3x(df = df, sample_rate = sample_rate, max_g = max_g)
  read.gt3x::is_gt3x(out)
  read.gt3x::have_log_and_info(out)
  x <- read.gt3x::read.gt3x(out, imputeZeroes = FALSE, asDataFrame = TRUE,
                            verbose = TRUE)
  df_x = as.data.frame(x)
  df_df = as.data.frame(df)
  stopifnot(isTRUE(
    all.equal(
      df_x[, c("time", "X", "Y", "Z")], 
      df_df[, c("time", "X", "Y", "Z")]
    )
  ))
}
#> Input is a .gt3x file, unzipping to a temporary location first...
#> Unzipping gt3x data to /var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpiI2jIw
#> 1/1
#> Unzipping /Library/Frameworks/R.framework/Versions/4.2/Resources/library/read.gt3x/extdata/TAS1H30182785_2019-09-17.gt3x
#>  === info.txt, log.bin extracted to /var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpiI2jIw/TAS1H30182785_2019-09-17
#> GT3X information
#>  $ Serial Number     :"TAS1H30182785"
#>  $ Device Type       :"Link"
#>  $ Firmware          :"1.7.2"
#>  $ Battery Voltage   :"4.18"
#>  $ Sample Rate       :100
#>  $ Start Date        : POSIXct, format: "2019-09-17 18:40:00"
#>  $ Stop Date         : POSIXct, format: "2019-09-18 19:00:00"
#>  $ Last Sample Time  : POSIXct, format: "2019-09-17 19:20:05"
#>  $ TimeZone          :"-04:00:00"
#>  $ Download Date     : POSIXct, format: "2019-09-17 19:20:05"
#>  $ Board Revision    :"8"
#>  $ Unexpected Resets :"0"
#>  $ Acceleration Scale:256
#>  $ Acceleration Min  :"-8.0"
#>  $ Acceleration Max  :"8.0"
#>  $ Subject Name      :"suffix_85"
#>  $ Serial Prefix     :"TAS"
#> Parsing GT3X data via CPP.. expected sample size: 240500
#> ---GT3X PARAMETERS
#> address: 0 key: 6 value: 1
#> address: 0 key: 7 value: 54703161
#> address: 0 key: 8 value: 8
#> address: 0 key: 9 value: 1534154836
#> address: 0 key: 13 value: 17235970
#> address: 0 key: 16 value: 3791650816
#> address: 0 key: 20 value: 0
#> address: 0 key: 21 value: 0
#> address: 0 key: 22 value: 0
#> address: 0 key: 23 value: 0
#> address: 0 key: 26 value: 2
#> address: 0 key: 28 value: 262013
#> address: 0 key: 29 value: 255
#> address: 0 key: 32 value: 16908288
#> address: 0 key: 37 value: 1024
#> address: 0 key: 38 value: 0
#> address: 0 key: 49 value: 2048
#> address: 0 key: 50 value: 88181047
#> address: 0 key: 51 value: 6.82667
#> address: 0 key: 55 value: 256
#> address: 0 key: 57 value: 333.87
#> address: 0 key: 58 value: 21
#> address: 0 key: 61 value: 2
#> address: 1 key: 0 value: 0
#> address: 1 key: 1 value: 872668711
#> address: 1 key: 2 (features)  value: 388
#> address: 1 key: 3 value: 1
#> address: 1 key: 4 value: 4294967131
#> address: 1 key: 5 value: 4294967095
#> address: 1 key: 6 value: 4294967149
#> address: 1 key: 7 value: 298
#> address: 1 key: 8 value: 286
#> address: 1 key: 9 value: 300
#> address: 1 key: 10 value: 100
#> address: 1 key: 12 (start time)  value: 1568745600
#> address: 1 key: 13 value: 1568833200
#> address: 1 key: 14 value: 1568745556
#> address: 1 key: 15 value: 74
#> address: 1 key: 16 value: 40
#> address: 1 key: 17 value: 72
#> address: 1 key: 20 value: 0
#> address: 1 key: 21 value: 0
#> address: 1 key: 33 value: 60000
#> address: 1 key: 34 value: 4294965247
#> address: 1 key: 35 value: 4294965190
#> address: 1 key: 36 value: 4294965237
#> address: 1 key: 37 value: 2051
#> address: 1 key: 38 value: 2000
#> address: 1 key: 39 value: 2048
#> address: 1 key: 40 value: 0
#> address: 1 key: 41 value: 1
#> address: 1 key: 42 value: 0
#> address: 1 key: 43 value: 4294967283
#> address: 1 key: 44 value: 0
#> address: 1 key: 45 value: 0
#> address: 1 key: 46 value: 0
#> ---END PARAMETERS
#> 
#> Activity with Sample Size of 0
#> payload start: 1568747741
#> total_records: 31800
#> max_samples: 240500
#> Activity with Sample Size of 0
#> payload start: 1568747759
#> total_records: 33000
#> max_samples: 240500
#> Total Records: 33000
#> Scaling...
#> Removing excess rows 
#> Sum of missingness is: 183000
#> Finding missingness amount: 24500
#> Creating dimnames 
#> CPP returning
#> Done (in 0.0689959526062012 seconds)
#> Input is a .gt3x file, unzipping to a temporary location first...
#> Unzipping gt3x data to /var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpiI2jIw
#> 1/1
#> Unzipping /var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpiI2jIw/file112d27caff1f.gt3x
#>  === info.txt, log.bin extracted to /var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpiI2jIw/file112d27caff1f
#> GT3X information
#>  $ Serial Number     :"MOS2F00000000"
#>  $ Device Type       :"wGT3XBT"
#>  $ Firmware          :"1.9.2"
#>  $ Battery Voltage   :"4.00"
#>  $ Sample Rate       :100
#>  $ Start Date        : POSIXct, format: "2019-09-17 18:40:00"
#>  $ Stop Date         : POSIXct, format: "2019-09-17 19:15:59"
#>  $ Last Sample Time  : POSIXct, format: "2019-09-17 19:15:59"
#>  $ TimeZone          :"00:00:00"
#>  $ Board Revision    :"4"
#>  $ Unexpected Resets :"0"
#>  $ Acceleration Scale:256
#>  $ Acceleration Min  :"-8.0"
#>  $ Acceleration Max  :"8.0"
#>  $ Subject Name      :"FAKEGT3X"
#>  $ Serial Prefix     :"MOS"
#>  $ Download Date     : 'POSIXct' num(0) 
#>  - attr(*, "tzone")= chr "GMT"
#> Parsing GT3X data via CPP.. expected sample size: 215900
#> Total Records: 33000
#> Scaling...
#> Removing excess rows 
#> Sum of missingness is: 182900
#> Finding missingness amount: 0
#> Creating dimnames 
#> CPP returning
#> Done (in 0.0711710453033447 seconds)
```
