# Reusable base-R helpers for the regression course.

#' Classify observed minutes using a threshold.
#'
#' @param minutes Numeric vector. Missing values are retained as "missing".
#' @param threshold Single finite numeric cutoff.
#' @return An ordered factor with levels fast, slow, missing.
classify_minutes <- function(minutes, threshold = 45) {
  stopifnot(is.numeric(minutes), length(threshold) == 1L,
            is.finite(threshold))
  label <- ifelse(
    is.na(minutes), "missing",
    ifelse(minutes <= threshold, "fast", "slow")
  )
  factor(label, levels = c("fast", "slow", "missing"), ordered = TRUE)
}

#' Summarize minutes by shift with base R.
#'
#' @param data Data frame containing shift and minutes columns.
#' @return Data frame with group, number observed, and mean minutes.
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

# Example:
# classify_minutes(c(30, 50, NA), threshold = 45)
