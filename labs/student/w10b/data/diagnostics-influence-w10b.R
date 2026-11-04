# W09B: additive, numeric, unweighted full-rank OLS diagnostics.
# Source diagnostics.R first. No data mutation, network or automatic deletion.

diag_validate_ols <- function(fit) {
  if (!identical(class(fit), "lm")) stop("Use an ordinary univariate lm, not rlm/glm/aov.")
  diag_validate_fit(fit)
  mf <- model.frame(fit); tt <- terms(fit)
  if (attr(tt, "intercept") != 1L || any(attr(tt, "order") != 1L) ||
      !is.symbol(formula(fit)[[2]]) ||
      !all(vapply(as.list(attr(tt,"variables"))[-1L],is.symbol,logical(1))) ||
      !identical(attr(tt,"term.labels"), names(mf)[-1L]) ||
      !all(vapply(mf, is.numeric, logical(1))) ||
      any(!is.finite(as.matrix(mf))))
    stop("Use an intercept and plain finite numeric additive variables on identical complete rows.")
  invisible(fit)
}

# lm -> one row per original observation; p = predictors, k = p+1.
# Cook uses full-data scale; DFFITS uses deleted scale.
# P-R plot: x = residual_component, y = potential; Hadi is their sum.
diag_influence <- function(fit) {
  diag_validate_ols(fit)
  z <- diag_residuals(fit)
  k <- fit$rank; SSE <- deviance(fit)
  ok <- 1-z$h > 1e-10
  Cook <- DFFITS <- potential <- residual_component <- rep(NA_real_, nrow(z))
  Cook[ok] <- z$internal[ok]^2 / k * z$h[ok] / (1-z$h[ok])
  deleted_ok <- ok & is.finite(z$external)
  DFFITS[deleted_ok] <- z$external[deleted_ok]*sqrt(z$h[deleted_ok]/(1-z$h[deleted_ok]))
  d2 <- z$raw^2/SSE
  potential[ok] <- z$h[ok]/(1-z$h[ok])
  hadi_ok <- ok & is.finite(d2) & (1-d2>0)
  residual_component[hadi_ok] <- k/(1-z$h[hadi_ok])*d2[hadi_ok]/(1-d2[hadi_ok])
  data.frame(z, Cook=Cook, DFFITS=DFFITS, normalized_squared=d2,
    potential=potential, residual_component=residual_component,
    Hadi=potential+residual_component, n=nobs(fit), k=k, df=df.residual(fit))
}

# Actual leave-one-out OLS refit on the SAME design, then predictions on ALL rows.
# An undefined deletion (rank loss, h=1) is reported, not replaced by zero.
diag_deleted_fit <- function(fit, i) {
  diag_validate_ols(fit)
  n <- nobs(fit); X <- model.matrix(fit); y <- model.response(model.frame(fit))
  if (length(i)!=1L || !is.numeric(i) || !is.finite(i) || i!=as.integer(i) || i<1 || i>n)
    stop("i must identify one original observation, from 1 to n.")
  reduced <- lm.fit(X[-i,,drop=FALSE], y[-i])
  if (reduced$rank!=ncol(X) || 1-hatvalues(fit)[i]<=1e-10)
    return(list(status="undefined: deletion loses rank (h=1)", row=i,
                coefficients=rep(NA_real_,ncol(X)), Cook=NA_real_, s_deleted=NA_real_))
  predicted <- as.numeric(X %*% reduced$coefficients)
  difference <- as.numeric(fitted(fit))-predicted
  SSE_deleted <- sum(reduced$residuals^2)
  list(status=if(SSE_deleted<=.Machine$double.eps) "deleted variance is zero or numerically unstable" else "ok",
       row=i, coefficients=setNames(reduced$coefficients,colnames(X)),
       Cook=sum(difference^2)/(fit$rank*sigma(fit)^2),
       s_deleted=sqrt(SSE_deleted/(df.residual(fit)-1)),
       predictions=data.frame(row=seq_len(n),full=as.numeric(fitted(fit)),deleted=predicted,difference=difference))
}
