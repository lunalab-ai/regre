# W10B: inspectable traces for numeric additive unweighted OLS.
# Source diagnostics.R, diagnostics-influence.R, diagnostics-effects.R first.
# Pure calculations: no network, installation, data mutation or automatic deletion.

# fit: validated lm; row: one original integer row in 1:n.
# Return: status, original-row prediction changes, diagnostic score and scales.
# Difference always means FULL minus DELETED, including the omitted location.
w10b_deletion_trace <- function(fit, row) {
  deleted <- diag_deleted_fit(fit, row)
  scores <- diag_influence(fit)[row,,drop=FALSE]
  if (is.null(deleted$predictions))
    return(list(status=deleted$status, predictions=NULL, score=scores,
                n=nobs(fit), k=fit$rank, df=df.residual(fit)))
  trace <- deleted$predictions
  trace$squared_change <- trace$difference^2
  trace$cumulative_squared_change <- cumsum(trace$squared_change)
  list(status=deleted$status, predictions=trace, score=scores,
       coefficients=deleted$coefficients, n=nobs(fit), k=fit$rank,
       df=df.residual(fit), s=sigma(fit), s_deleted=deleted$s_deleted,
       numerator=sum(trace$squared_change), denominator=fit$rank*sigma(fit)^2,
       Cook_from_predictions=deleted$Cook)
}

# fit: same numeric additive lm; variable: one exact existing predictor name.
# Return one row per SAME model-frame row; original units are preserved.
# Auxiliary predictions are the complementary projections from the AV helper.
w10b_effect_trace <- function(fit, variable) {
  av <- diag_added_variable(fit, variable)
  cp <- diag_component_residual(fit, variable)
  mf <- model.frame(fit)
  observed <- as.numeric(model.response(mf)); x <- mf[[variable]]
  list(variable=variable, n=nobs(fit), k=fit$rank, df=df.residual(fit),
       controlled=setdiff(names(mf)[-1L],variable), coefficient=av$coefficient,
       av_slope=av$slope,
       data=data.frame(row=seq_along(x), x=x, observed=observed,
         auxiliary_x=x-av$data$x_residual,
         auxiliary_y=observed-av$data$y_residual,
         av_x=av$data$x_residual, av_y=av$data$y_residual,
         fitted=as.numeric(fitted(fit)), residual=cp$residual,
         component=cp$component, cpr_x=cp$x, cpr_y=cp$component_residual))
}

# Return inputs and Hadi components for one original row. P-R axes are x=R,y=P.
# These components are not probabilities and R does not retain the residual sign.
w10b_pr_trace <- function(fit, row) {
  if (length(row)!=1L || !is.numeric(row) || !is.finite(row) ||
      row!=as.integer(row) || row<1 || row>nobs(fit))
    stop("row must identify one original observation.")
  z <- diag_influence(fit)[row,,drop=FALSE]
  data.frame(row=row,n=nobs(fit),k=fit$rank,e=z$raw,h=z$h,
             SSE=deviance(fit),d_squared=z$normalized_squared,
             P=z$potential,R=z$residual_component,Hadi=z$Hadi)
}

# u: finite numeric standardized residuals; c: positive scalar, default Huber 1.345.
# Return dimensionless loss and residual weights. High leverage is not an input.
w10b_huber_trace <- function(u, c=1.345) {
  if (!is.numeric(u) || !length(u) || any(!is.finite(u)) ||
      length(c)!=1L || !is.numeric(c) || !is.finite(c) || c<=0)
    stop("Use finite numeric residuals and one positive tuning constant.")
  a <- abs(u)
  data.frame(u=u,quadratic_loss=.5*u^2,
             huber_loss=ifelse(a<=c,.5*u^2,c*(a-.5*c)),
             weight=ifelse(a<=c,1,c/a))
}
