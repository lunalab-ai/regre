# W04A reusable inference tools. Base R only; no download or input mutation.
# Version: 2026-fall-w04a. Units = parts; Minutes = minutes.
# API: https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-api.md

# prediction_intervals(model, units, level=.95, interval="confidence")
# model: full-rank unweighted lm(Minutes ~ Units), positive residual variance/df.
# units: nonempty finite numeric vector, preserved in input order.
# level: scalar in (0,1); interval: exactly confidence or prediction.
# Returns data.frame: Units, fit, lower, upper, width (minutes), kind, level,
# extrapolation (outside training Units range). No refit or side effects.
# Example: prediction_intervals(fit_repair(repair), 4): fit about 66.197 minutes.
prediction_intervals <- function(model, units, level=.95, interval="confidence") {
  if (!inherits(model,"lm") || !identical(names(coef(model)),c("(Intercept)","Units")) ||
      model$rank != 2L || df.residual(model) <= 0 || !is.null(model$weights) || !is.null(model$offset))
    stop("model must be a full-rank, unweighted lm with intercept and Units")
  if (!is.numeric(units) || !length(units) || any(!is.finite(units)))
    stop("units must be a nonempty finite numeric vector")
  if (!is.numeric(level) || length(level)!=1L || !is.finite(level) || level<=0 || level>=1)
    stop("level must be one number between 0 and 1")
  if (!is.character(interval) || length(interval)!=1L || is.na(interval) ||
      !interval %in% c("confidence","prediction")) stop("interval must be confidence or prediction")
  mf <- model.frame(model)
  if (!is.numeric(mf$Units) || any(!is.finite(mf$Units)) || !is.numeric(model.response(mf)) ||
      !is.finite(summary(model)$sigma) || summary(model)$sigma<=0) stop("invalid model data or variance")
  ans <- predict(model,newdata=data.frame(Units=units),interval=interval,level=level)
  bounds <- range(mf$Units)
  data.frame(Units=units,fit=unname(ans[,"fit"]),lower=unname(ans[,"lwr"]),
             upper=unname(ans[,"upr"]),width=unname(ans[,"upr"]-ans[,"lwr"]),
             kind=interval,level=level,extrapolation=units<bounds[1] | units>bounds[2])
}

# regression_fit_summary(model): unweighted full-rank numeric-response lm -> one row.
# n,p,df: counts; SSE/SST/SSR: squared response units; RSE: response units.
# R_squared uses the same baseline as summary.lm (mean if intercept, zero otherwise).
# R_squared_centered always uses the mean baseline; it can be negative.
# SSR_centered is sum((fitted-mean(y))^2); SST=SSR+SSE requires an intercept.
# Zero denominators return NA. No fitting, downloads, or changes to model/data.
regression_fit_summary <- function(model) {
  if (!inherits(model,"lm") || !is.null(model$weights) || !is.null(model$offset) ||
      model$rank!=length(coef(model)) || df.residual(model)<=0) stop("unsupported lm")
  y <- model.response(model.frame(model))
  if (!is.numeric(y) || is.matrix(y) || any(!is.finite(y))) stop("finite numeric response required")
  has_intercept <- attr(terms(model),"intercept")==1L
  sse <- sum(residuals(model)^2); sst <- sum((y-mean(y))^2)
  denominator <- if(has_intercept) sst else sum(y^2)
  data.frame(n=length(y),p=model$rank,df=df.residual(model),SSE=sse,SST_centered=sst,
    SSR_centered=sum((fitted(model)-mean(y))^2),RSE=sqrt(sse/df.residual(model)),
    residual_sum=sum(residuals(model)),baseline=if(has_intercept) "mean" else "zero",
    R_squared=if(denominator>0) 1-sse/denominator else NA_real_,
    R_squared_centered=if(sst>0) 1-sse/sst else NA_real_,decomposition_valid=has_intercept)
}
