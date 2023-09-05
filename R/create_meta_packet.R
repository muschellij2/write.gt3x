create_meta_packet = function(subject_name = "FAKEGT3X") {
  values = list(
    MetadataType = "Bio",
    SubjectName = subject_name,
    Gender = "",
    Race = "",
    Limb = "Wrist",
    Side = "Left",
    Dominance = "Non-Dominant",
    Parsed = FALSE,
    JSON = NA)
  packet = jsonlite::toJSON(values, auto_unbox = TRUE)
  packet = as.character(packet)
  payload = charToRaw(packet)

  packet_timestamp = lubridate::with_tz(Sys.time(), "UTC")
  packet_timestamp = as.integer(packet_timestamp)

  size = length(payload) # 2 bytes
  size = as.integer(size)
  checksum = 8L + size

  # writeBin("\x1e"
  header = c(
    # # log separator
    # writeBin("\x1e", raw(0), size=1L, endian="little"),
    # # ACTIVITY2 Packet
    # writeBin("\x1a", raw(0), size=1L, endian="little"),
    # log separator
    # writeBin("\x1e", raw(0), size=1L, endian="little", useBytes = TRUE)[1],
    as.raw(0x1e),
    # metadata
    as.raw(0x06),
    # writeBin("\x1e", raw(0), size=1L, endian="little", useBytes = TRUE)[1],
    # \x1a
    # timestamp
    # 1421142129L
    # writeBin(1490718600L, raw(0), size = 4L, endian = "little"),
    writeBin(packet_timestamp, raw(0), size = 4L, endian = "little"),
    # size in bytes
    writeBin(size, raw(0), size = 2L, endian = "little")[1:2],
    # payload/data
    # writeBin(payload, raw(0), endian = "little"),
    payload,
    writeBin(checksum, raw(0), endian = "little", size = 1L)[1]
  )

  return(packet)
}
