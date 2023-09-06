extract_packet = function(raw_vec, check_type = 0x06) {
  stopifnot(
    raw_vec[[1]] == 0x1e,
    raw_vec[[2]] == check_type
  )
  timestamp = readBin(raw_vec[3:6], what = integer())
  timestamp = lubridate::as_datetime(timestamp)
  size = readBin(raw_vec[7:8], what = integer(), size = 2)
  payload = raw_vec[9:(9+size-1)]
  checksum = raw_vec[9+size]
  list(
    payload = payload,
    checksum = checksum,
    size = size,
    timestamp = timestamp,
    raw_vec = raw_vec
  )
}

read_metadata = function(raw_vec) {
  out = extract_packet(raw_vec = raw_vec, check_type = 0x06)
  out$payload = readBin(out$payload, what = character())
  out
}


read_parameters = function(raw_vec) {
  out = extract_packet(raw_vec, 0x15)
  out
}
