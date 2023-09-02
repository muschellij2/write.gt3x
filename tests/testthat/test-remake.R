testthat::test_that("Reread the file works", {
  testthat::skip_if_not_installed("read.gt3x")
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
  testthat::expect_equal(
    df_x[, c("time", "X", "Y", "Z")],
    df_df[, c("time", "X", "Y", "Z")]
  )
  testthat::expect_warning(write_gt3x(df = df,
                                      sample_rate = sample_rate,
                                      max_g = "6"))
})
