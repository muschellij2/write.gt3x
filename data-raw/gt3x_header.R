## code to prepare `gt3x_header` dataset goes here
library(dplyr)
library(agcounts)
library(read.gt3x)
file <- system.file(
  "extdata", "TAS1H30182785_2019-09-17.gt3x",
  package = "read.gt3x")
# file = system.file("extdata", "example.gt3x", package = "agcounts")
exdir = tempdir()
result = agcounts::agread(file, "pygt3x")
gt = read.gt3x::read.gt3x(file, verbose = TRUE, asDataFrame = TRUE)
files = unzip(file, exdir = exdir)
info_file = files[grepl("info", files)]
readLines(info_file)
bin_file = files[grepl("log.bin", files)]
n_bytes = file.size(bin_file)
start = readBin(bin_file, raw(), n = n_bytes)
df = tibble::tibble(
  value = start,
  record = start == 0x1e
) %>%
  dplyr::mutate(type = dplyr::lag(record, default = FALSE),
                record_ind = cumsum(record)
  )
keep_ind = df %>%
  filter(type) %>%
  distinct(value, record_ind)
last_header_record = keep_ind$record_ind[which(keep_ind$value == 0x1a)[1] - 1]
df = df %>%
  filter(record_ind <= last_header_record)
full_gt3x_header = df$value

usethis::use_data(full_gt3x_header, overwrite = TRUE)

last_header_record = keep_ind$record_ind[which(keep_ind$value == 0x15)[1]]
df = df %>%
  filter(record_ind <= last_header_record)
gt3x_header = df$value
usethis::use_data(gt3x_header, overwrite = TRUE)
