# Browser-distributable copy of src/r-syntax-tools.R.
# Keep this file identical in behavior to the public reusable source.

classify_minutes <- function(minutes, threshold = 45) {
  stopifnot(is.numeric(minutes), length(threshold) == 1L,
            is.finite(threshold))
  label <- ifelse(
    is.na(minutes), "missing",
    ifelse(minutes <= threshold, "fast", "slow")
  )
  factor(label, levels = c("fast", "slow", "missing"), ordered = TRUE)
}

summarize_by_shift <- function(data) {
  stopifnot(is.data.frame(data), all(c("shift", "minutes") %in% names(data)))
  groups <- split(data$minutes, data$shift, drop = TRUE)
  data.frame(
    shift = names(groups),
    n_observed = vapply(groups, function(x) sum(!is.na(x)), integer(1)),
    mean_minutes = vapply(groups, function(x) mean(x, na.rm = TRUE), numeric(1)),
    row.names = NULL
  )
}
