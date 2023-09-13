create_csv_header = function(
    df,
    sample_rate = 30L,
    max_g = c("8", "6")
) {

  start_datetime = lubridate::with_tz(df$time[1], "UTC")
  start_datetime = lubridate::floor_date(start_datetime)

  # convert to UTC
  time_zone = "00:00:00"

  max_g = match.arg(max_g)
  serial_prefix = switch(
    max_g,
    "6" = "CLE2F",
    "8" = "MOS2F")

  serial_number = paste0(serial_prefix,
                         paste(rep("0", 13 - nchar(serial_prefix)),
                               collapse = ""))
  device_type = switch(
    max_g,
    "6" = "GT3X+",
    "8" = "wGT3X-BT")

  board_revision = switch(
    max_g,
    "6" = "1",
    "8" = "4"
  )
  battery_voltage = "4.00"

  firmware = switch(
    max_g,
    "6" = "2.5.0",
    "8" = "1.9.2"
  )
  start_date = lubridate::as_date(start_datetime)
  start_date = format(start_date, "%m/%d/%Y")
  start_time = format(start_datetime, "%H:%M:%S")

  download_datetime = lubridate::with_tz(Sys.time(), "UTC")
  download_date = lubridate::as_date(download_datetime)
  download_date = format(download_date, "%m/%d/%Y")
  download_time = format(download_datetime, "%H:%M:%S")

  start_date <- gsub("^0", "", start_date)
  download_date <- gsub("^0", "", download_date)
  mode = 12

  header = c(
    paste0("------------",
           "Data File Created By ActiGraph ", device_type, " ActiLife v6.13.3 ",
           "Firmware v", firmware, " ",
           "date format M/d/yyyy at ", sample_rate, " Hz",
           "-----------"),
    paste0("Serial Number: ", serial_number),
    paste0("Start Time ", start_time),
    paste0("Start Date ", start_date), #  3/8/2016
    paste0("Epoch Period (hh:mm:ss) ", "00:00:00"),
    paste0("Download Time ", download_time),
    paste0("Download Date ", download_date),
    paste0("Current Memory Address: ", 0),
    paste0("Current Battery Voltage: ", battery_voltage, "     Mode = ", mode),
    "--------------------------------------------------"
  )
}

#' Write a CSV file for Actigraph
#'
#' @param df A `data.frame` of `time`, and `X`, `Y`, `Z`
#' @param file output CSV file
#' @param sample_rate sampling frequency of the data
#' @param max_g max value (in g) of the device the data was from. If unsure,
#' use `"8"`
#' @param ... additional arguments to pass to [readr::write_csv()]
#'
#' @return The CSV file path output.
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
#'   out = write_actigraph_csv(df = df, sample_rate = sample_rate, max_g = max_g,
#'                             num_threads = 1)
#' }
write_actigraph_csv = function(
    df,
    file = tempfile(fileext = ".csv"),
    sample_rate = 30L,
    max_g = c("8", "6"),
    ...
) {
  X = Y = Z = NULL
  rm(list = c("X", "Y", "Z"))
  df$time = lubridate::with_tz(df$time, "UTC")

  header = create_csv_header(
    df = df,
    sample_rate = sample_rate,
    max_g = max_g)
  df = df %>%
    dplyr::select("Accelerometer X" = X,
                  "Accelerometer Y" = Y,
                  "Accelerometer Z" = Z)
  writeLines(header, file)
  readr::write_csv(
    df,
    file = file,
    append = TRUE,
    col_names = TRUE,
    ...)
  return(file)
}
