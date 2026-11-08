# Inspectable categorical OLS operations. Base R, no I/O or automatic row deletion.
# The teaching notebooks display these exact definitions, generated from this file.

# Standard, unweighted, full-rank lm with stored complete rows -> checked frame.
cat_check_fit <- function(fit) {
  if (!inherits(fit,"lm") || !is.data.frame(fit$model))
    stop("Use a standard lm with its complete model frame retained.")
  frame <- fit$model
  design <- model.matrix(fit)
  y <- model.response(frame)
  if (!is.numeric(y) || is.matrix(y) || any(!is.finite(y)) ||
      any(!is.finite(design)) || !is.null(model.weights(frame)) ||
      !is.null(model.offset(frame)) || fit$rank!=ncol(design) ||
      df.residual(fit)<1L || any(!is.finite(coef(fit))))
    stop("Require finite, unweighted, no-offset, full-rank univariate OLS with residual df.")
  frame
}

# lm + complete newdata -> one contribution row per observation AND term.
# Summing contribution within row equals predict(fit,newdata), in response units.
cat_row_trace <- function(fit, newdata) {
  cat_check_fit(fit)
  if (!is.data.frame(newdata) || nrow(newdata)<1L)
    stop("newdata must contain at least one complete observation.")
  term <- delete.response(terms(fit))
  frame <- model.frame(term,newdata,na.action=na.fail,xlev=fit$xlevels)
  design <- model.matrix(term,frame,contrasts.arg=fit$contrasts)
  beta <- coef(fit)
  if (!identical(colnames(design),names(beta)) || any(!is.finite(design)))
    stop("New rows must use the fitted columns, factor levels and finite values.")
  contribution <- sweep(design,2,beta,"*")
  data.frame(row=rep(seq_len(nrow(design)),each=ncol(design)),
    term=rep(colnames(design),times=nrow(design)),
    value=as.vector(t(design)),coefficient=rep(unname(beta),times=nrow(design)),
    contribution=as.vector(t(contribution)),row.names=NULL)
}

# lm -> actual design, QR coefficients, fitted/residual/square/cumulative table.
# No inverse of X'X is used. lm itself uses QR for this unweighted OLS contract.
cat_fit_trace <- function(fit) {
  frame <- cat_check_fit(fit)
  design <- model.matrix(fit)
  observed <- model.response(frame)
  beta <- qr.coef(qr(design),observed)
  fitted <- drop(design %*% beta)
  residual <- observed-fitted
  squared <- residual^2
  rows <- data.frame(source_row=rownames(design),observed=unname(observed),
    fitted=unname(fitted),residual=unname(residual),squared=unname(squared),
    cumulative=cumsum(unname(squared)),row.names=NULL)
  list(design=design,coefficients=beta,rows=rows,
    SSE=sum(squared),n=nrow(design),k=ncol(design),df=df.residual(fit))
}

# Original TEST/RACE/JPERF complete rows -> four explicitly restricted models.
# RACE is the original numeric 0/1 code; this function never drops source rows.
cat_two_group_models <- function(data) {
  columns <- c("TEST","RACE","JPERF")
  if (!is.data.frame(data) || !all(columns %in% names(data)) || nrow(data)<6L ||
      !all(vapply(data[columns],is.numeric,logical(1))) ||
      any(!is.finite(as.matrix(data[columns]))) ||
      any(!data$RACE %in% 0:1) || length(unique(data$RACE))!=2L)
    stop("Use complete finite TEST/RACE/JPERF rows with both original 0/1 groups.")
  models <- list(M0=lm(JPERF~TEST,data,na.action=na.fail),
    MI=lm(JPERF~TEST+RACE,data,na.action=na.fail),
    MS=lm(JPERF~TEST+TEST:RACE,data,na.action=na.fail),
    MF=lm(JPERF~TEST*RACE,data,na.action=na.fail))
  invisible(lapply(models,cat_check_fit))
  models
}

# Validate identical rows/response and column-space nesting, without refitting.
cat_check_pair <- function(reduced, full, tolerance=1e-9) {
  r <- cat_check_fit(reduced)
  f <- cat_check_fit(full)
  if (!identical(rownames(r),rownames(f)) ||
      !isTRUE(all.equal(model.response(r),model.response(f),tolerance=0)))
    stop("Compare the same response and identical observations in identical order.")
  xr <- model.matrix(reduced)
  xf <- model.matrix(full)
  if (length(tolerance)!=1L || !is.numeric(tolerance) ||
      !is.finite(tolerance) || tolerance<=0) stop("Use positive finite tolerance.")
  q <- full$rank-reduced$rank
  if (q<=0 || max(abs(qr.resid(qr(xf),xr)))>tolerance*max(1,abs(xr)))
    stop("Reduced design must be nested in full design with fewer parameters.")
  list(n=nrow(f),q=q,df_full=df.residual(full))
}

# Two nested OLS fits on identical observed y AND identical row identities -> F.
# MI and MS are not nested. Equal sizes alone do not establish identical rows.
cat_nested_trace <- function(reduced, full, tolerance=1e-9) {
  checked <- cat_check_pair(reduced,full,tolerance)
  SSE_reduced <- sum(residuals(reduced)^2)
  SSE_full <- sum(residuals(full)^2)
  if (SSE_full<=0 ||
      SSE_reduced<SSE_full-tolerance*max(1,SSE_reduced))
    stop("F needs positive full-model residual variance and a valid nested SSE.")
  q <- checked$q
  df_full <- checked$df_full
  # A tiny negative difference can only be numerical roundoff for nested OLS.
  increase <- max(0,SSE_reduced-SSE_full)
  F <- (increase/q)/(SSE_full/df_full)
  data.frame(n=checked$n,k_reduced=reduced$rank,k_full=full$rank,q=q,
    df_full=df_full,SSE_reduced=SSE_reduced,SSE_full=SSE_full,
    F=F,p=pf(F,q,df_full,lower.tail=FALSE))
}

# One of the TEST/RACE teaching fits -> intercept/slope for each original group.
# Absent terms are explicit zero restrictions, not estimated zero coefficients.
cat_group_lines <- function(fit) {
  cat_check_fit(fit)
  beta <- c("(Intercept)"=0,"TEST"=0,"RACE"=0,"TEST:RACE"=0)
  if (!all(names(coef(fit)) %in% names(beta)))
    stop("Use a TEST/RACE model from this two-group comparison.")
  beta[names(coef(fit))] <- coef(fit)
  Z <- 0:1
  data.frame(Z=Z,intercept=unname(beta["(Intercept)"]+beta["RACE"]*Z),
    slope=unname(beta["TEST"]+beta["TEST:RACE"]*Z))
}

# Finite intercept gap gamma, slope gap delta, numeric x -> group1 minus group0.
cat_gap <- function(gamma, delta, x) {
  if (length(gamma)!=1L || length(delta)!=1L || !is.numeric(gamma) ||
      !is.numeric(delta) || !is.numeric(x) || !length(x) ||
      any(!is.finite(c(gamma,delta,x)))) stop("Use finite scalar gaps and finite x.")
  gamma+delta*x
}
