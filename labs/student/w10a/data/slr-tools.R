# W03B reusable simple-regression functions. Base R stats only.
# fit_repair(data): data.frame with numeric Units (parts) and Minutes (minutes).
# Requires >=3 complete finite rows and nonconstant Units; rejects missing data
# rather than silently changing the sample. Returns an intercept-including lm
# object fitted by least squares, in the original row order. Does not mutate
# data, download files or install packages. Example: fit_repair(repair).
fit_repair <- function(data) {
  if (!is.data.frame(data) || !all(c("Units", "Minutes") %in% names(data)))
    stop("data needs numeric Units and Minutes columns.")
  if (!is.numeric(data$Units) || !is.numeric(data$Minutes) || nrow(data) < 3L ||
      any(!is.finite(data$Units)) || any(!is.finite(data$Minutes)))
    stop("Use at least 3 complete, finite numeric observations.")
  if (sum((data$Units - mean(data$Units))^2) <= 0)
    stop("Units must vary: the slope is not identifiable.")
  stats::lm(Minutes ~ Units, data = data, na.action = stats::na.fail)
}

# coefficient_inference(model, level=.95, null_slope=0): model is an lm returned
# by fit_repair or equivalent lm(Minutes ~ Units, data). level is a finite scalar
# strictly between 0 and 1; null_slope is a finite scalar in minutes/part.
# Returns two rows, (Intercept) then Units, and columns term, estimate, se, df,
# null, t_value, p_value, lower, upper, reject. Intercept null stays zero.
# Estimates/SE/limits use minutes or minutes/part; t, p and level are unitless.
# Two-sided t inference at alpha=1-level assumes independent normal errors of
# common variance with a correct linear conditional mean. CI is marginal per
# coefficient, not a prediction interval or a joint confidence region.
# No fitting/mutation/download: only summaries of the supplied fitted object.
# Example: coefficient_inference(fit_repair(repair), .95, 12).
coefficient_inference <- function(model, level = 0.95, null_slope = 0) {
  scalar <- function(z) is.numeric(z) && length(z) == 1L && is.finite(z)
  if (!scalar(level) || level <= 0 || level >= 1) stop("level must be between 0 and 1.")
  if (!scalar(null_slope)) stop("null_slope must be one finite number.")
  if (!inherits(model, "lm") || model$rank != 2L ||
      !identical(names(stats::coef(model)), c("(Intercept)", "Units")) ||
      stats::df.residual(model) <= 0L)
    stop("Supply a full-rank, intercept-including Minutes ~ Units model.")
  sm <- summary(model)
  if (!is.finite(sm$sigma) || sm$sigma <= sqrt(.Machine$double.eps))
    stop("Residual variation is too small for this teaching inference routine.")
  tab <- sm$coefficients
  est <- tab[, "Estimate"]; se <- tab[, "Std. Error"]
  df <- stats::df.residual(model); null <- c(0, null_slope)
  t_value <- (est - null) / se
  p_value <- 2 * stats::pt(-abs(t_value), df = df)
  radius <- stats::qt((1 + level)/2, df = df) * se
  data.frame(term = names(est), estimate = unname(est), se = unname(se),
             df = df, null = null, t_value = unname(t_value),
             p_value = unname(p_value), lower = unname(est - radius),
             upper = unname(est + radius), reject = p_value < (1 - level),
             row.names = NULL)
}
