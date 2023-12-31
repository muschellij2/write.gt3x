# read.gt3x::datetime2ticks
datetime2ticks = function (x) {
  timezone = attr(x, "tzone")
  if (is.null(timezone)) {
    timezone = attr(as.POSIXlt(x), "tzone")
    if (!is.null(timezone)) {
      timezone = setdiff(timezone, "")[1]
    }
  }
  if (is.null(timezone) || length(timezone) == 0 || !timezone %in%
      c("GMT", "UTC")) {
    warning(paste0("date time object not in UTC/GMT, should use ",
                   "lubridate::with_tz or lubridate::tz to change before making ticks"))
  }
  days = difftime(as.Date(x), as.Date("0001-01-01"), units = "days")
  days = as.double(days)
  seconds = difftime(x, as.POSIXct(paste0(as.Date(x), " 00:00:00"),
                                   tz = timezone), units = "secs")
  seconds = as.double(seconds)
  seconds = round(seconds, 3)
  ticks = days * 86400 + seconds
  ticks = round(ticks * 1000)
  ticks = format(ticks, scientific = FALSE)
  ticks = paste0(ticks, "0000")
  ticks
}


create_packet = function(packet, scale = 341L) {

  packet_timestamp = unique(packet$second)
  packet_timestamp = as.integer(packet_timestamp)

  payload = packet[, c("X", "Y", "Z")]
  rm(packet)

  payload = round(payload * scale)
  payload = c(t(payload))
  payload = as.integer(payload)
  size = length(payload) * 2L # 2 bytes
  size = as.integer(size)
  # checksum = 8L + size

  # writeBin("\x1e"
  header = c(
    # # log separator
    # writeBin("\x1e", raw(0), size=1L, endian="little"),
    # # ACTIVITY2 Packet
    # writeBin("\x1a", raw(0), size=1L, endian="little"),
    # log separator
    writeBin("\x1e\x1a", raw(0), size=2L, endian="little", useBytes = TRUE)[1:2],
    # timestamp
    # 1421142129L
    # writeBin(1490718600L, raw(0), size = 4L, endian = "little"),
    writeBin(packet_timestamp, raw(0), size = 4L, endian = "little"),
    # size in bytes
    writeBin(size, raw(0), size = 2L, endian = "little")[1:2],
    # payload/data
    writeBin(payload, raw(0), endian = "little", size = 2L)
  )
  checksum = writeBin(checksum_from_header(header), raw(0),
                      endian = "little", size = 1L)[1]
  header = c(
    header,
    checksum
  )

}

create_info = function(
    df,
    sample_rate = 30L,
    max_g = c("8", "6"),
    acceleration_scale = NULL
) {

  df$time = lubridate::with_tz(df$time, "UTC")
  range_date = range(df$time, na.rm = TRUE)
  # convert to UTC
  time_zone = "00:00:00"
  range_date = c(
    lubridate::floor_date(range_date[1], "seconds"),
    lubridate::ceiling_date(range_date[2], "seconds")
  )
  range_date = datetime2ticks(range_date)

  max_g = match.arg(max_g)
  serial_prefix = switch(
    max_g,
    "6" = "CLE2F",
    "8" = "MOS2F")
  if (is.null(acceleration_scale)) {
    acceleration_scale = switch(
      max_g,
      "6" = 341L,
      "8" = 256L)
  }

  serial_number = paste0(serial_prefix,
                         paste(rep("0", 13 - nchar(serial_prefix)),
                               collapse = ""))
  device_type = switch(
    max_g,
    "6" = "wGT3XPlus",
    "8" = "wGT3XBT")
  dynamic_range = as.integer(max_g)
  dynamic_range = c(-dynamic_range, dynamic_range)

  #
  board_revision = switch(
    max_g,
    "6" = "1",
    "8" = "4"
  )
  unexpected_resets = "0"
  battery_voltage = "4.00"

  firmware = switch(
    max_g,
    "6" = "2.5.0",
    "8" = "1.9.2"
  )
  out = c(
    "Serial Number" = serial_number,
    "Device Type" = device_type,
    "Firmware" = firmware,
    "Battery Voltage" = battery_voltage,
    "Sample Rate" = as.integer(sample_rate),
    "Start Date" = range_date[1],
    "Stop Date" = range_date[2],
    "Last Sample Time" = range_date[2],
    # XXX,
    "TimeZone" = time_zone,
    "Board Revision" = board_revision,
    "Unexpected Resets" = unexpected_resets,
    "Acceleration Scale" = sprintf("%.1f", acceleration_scale),
    "Acceleration Min" = sprintf("%.1f", dynamic_range[1]),
    "Acceleration Max" = sprintf("%.1f", dynamic_range[2]),
    "Subject Name" = "FAKEGT3X"
  )
  return(out)
}

#' Write a GT3X file
#'
#' @param df A `data.frame` of `time`, and `X`, `Y`, `Z`
#' @param file output GT3X file
#' @param sample_rate sampling frequency of the data
#' @param max_g max value (in g) of the device the data was from. If unsure,
#' use `"8"`
#' @param acceleration_scale The rescaling factor to scale the data to integers.
#' Normally, this is determined by the `max_g` (technically the serial
#' number/model of the device).  NOTE: this may result in a malformed GT3X file
#' @param meta should a metadata header and other records be added?
#'
#' @return The GT3X file path output.
#' @export
#'
#' @examples
#' if (requireNamespace("read.gt3x", quietly = TRUE)) {
#'   gt3xfile <- system.file(
#'     "extdata", "TAS1H30182785_2019-09-17.gt3x",
#'     package = "read.gt3x")
#'   df <- read.gt3x::read.gt3x(
#'     gt3xfile, imputeZeroes = FALSE, asDataFrame = TRUE,
#'     verbose = TRUE)
#'   sample_rate = attr(df, "sample_rate")
#'   max_g = attr(df, "acceleration_max")
#'   max_g = as.character(as.integer(max_g))
#'   out = write_gt3x(df = df, sample_rate = sample_rate, max_g = max_g)
#'   read.gt3x::is_gt3x(out)
#'   read.gt3x::have_log_and_info(out)
#'   x <- read.gt3x::read.gt3x(out, imputeZeroes = FALSE, asDataFrame = TRUE,
#'                             verbose = TRUE)
#'   df_x = as.data.frame(x)
#'   df_df = as.data.frame(df)
#'   stopifnot(isTRUE(
#'     all.equal(
#'       df_x[, c("time", "X", "Y", "Z")],
#'       df_df[, c("time", "X", "Y", "Z")]
#'     )
#'   ))
#'   testthat::expect_warning(write_gt3x(df = df,
#'                                       sample_rate = sample_rate,
#'                                       max_g = "6"))
#' }
write_gt3x = function(
    df,
    file = tempfile(fileext = ".gt3x"),
    sample_rate = 30L,
    max_g = c("8", "6"),
    acceleration_scale = NULL,
    meta = c("none", "header", "full_header")
) {

  file = fs::path_abs(file)
  df$time = lubridate::with_tz(df$time, "UTC")
  max_g = match.arg(max_g)
  max_value = max(df[, c("X", "Y", "Z")])
  if (max_value > as.numeric(max_g)) {
    warning("Max Acceleration is larger than max_g!  Setting `max_g` to",
            "8")
    max_g = "8"
  }

  if (is.null(acceleration_scale)) {
    acceleration_scale = switch(
      max_g,
      "6" = 341L,
      "8" = 256L)
  }
  info = create_info(
    df = df,
    sample_rate = sample_rate,
    max_g = max_g,
    acceleration_scale = acceleration_scale
  )


  tdir = tempfile()
  dir.create(tdir, showWarnings = FALSE, recursive = TRUE)
  info_file = file.path(tdir, "info.txt")
  info = paste0(names(info), ": ", info)
  writeLines(info, con = info_file)

  quick_floor_second = function(x) {
    # lubridate::as_datetime(floor(as.numeric(x)))
    as.integer(floor(as.numeric(x)))
  }
  # df$second = strptime(
  #   lubridate::floor_date(df$time, "seconds"),
  #   format = "%Y-%m-%d %H:%M:%S",
  #   tz = "UTC")
  df$second = quick_floor_second(df$time)
  df$time = NULL
  packets = split(df, df$second)
  packets = unname(packets)
  rm(df);

  # packet = packets[[5]]

  header = pbapply::pblapply(packets, create_packet,
                             scale = acceleration_scale)
  header = unname(header)
  header = unlist(header)

  # if (add_meta) {
  #   meta_header = create_meta_packet()
  #   meta_header = unname(meta_header)
  #   meta_header = unlist(meta_header)
  #
  #   # need to fix this somehow
  #   param_header = params_packet()
  #   header = c(meta_header, param_header, header)
  # }
  meta = match.arg(meta)
  meta_header = switch(
    meta,
    none = NULL,
    header = write.gt3x::gt3x_header,
    full_header = write.gt3x::full_gt3x_header,
  )
  # if (add_meta) {
    header = c(meta_header, header)
  # }

  log_file = file.path(tdir, "log.bin")
  writeBin(header, con = log_file)

  owd = getwd()
  on.exit({
    setwd(owd)
  }, add = TRUE)
  setwd(tdir)
  utils::zip(file, files = c("log.bin", "info.txt"))
  setwd(owd)
  return(file)
}

