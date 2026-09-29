# W05A regression helpers | version: 2026-fall-w05a-v2
# Pure computations use base R; no downloads, package installation or input mutation.
# Canonical source: https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R

# Numeric complete data guard. Returns the original data invisibly; errors are explicit.
validate_numeric_frame <- function(data, columns) {
  if (!is.data.frame(data) || nrow(data) < 3L || !all(columns %in% names(data)))
    stop("Expected a data.frame with >=3 rows and columns: ", paste(columns, collapse=", "))
  if (!all(vapply(data[columns], function(x) is.numeric(x) && all(is.finite(x)), logical(1))))
    stop("Selected columns must be numeric and contain no NA/Inf.")
  invisible(data)
}

# No arguments -> four synthetic observations x/y, for meaning rather than inference.
four_points <- function() data.frame(x=1:4, y=c(2,4,4,6))

# data: complete numeric rating + predictors; percentages, one row per department.
# predictors: distinct character column names, default complaints and privileges.
# character(0) fits a mean-only model. Returns a full-rank, intercept-containing lm.
# Example: coef(fit_attitude())["complaints"] ~= 0.7803434 percentage points/point.
fit_attitude <- function(data=datasets::attitude, predictors=c("complaints","privileges")) {
  allowed <- setdiff(names(datasets::attitude),"rating")
  if (!is.character(predictors) || anyDuplicated(predictors) || !all(predictors %in% allowed))
    stop("Use distinct attitude predictor names; response rating cannot be a predictor.")
  validate_numeric_frame(data,c("rating",predictors))
  f <- if(length(predictors)) reformulate(predictors,response="rating") else rating~1
  fit <- lm(f,data=data)
  if (fit$rank != length(coef(fit)) || df.residual(fit) <= 0L)
    stop("Need independent model columns and positive residual degrees of freedom.")
  fit
}

# fit: unweighted full-rank lm with intercept and no offset, same training rows.
# Returns list(points, summary). Deviations retain response units; SS have squared units.
# R2 is NA when SST is zero; it is never silently replaced with zero or one.
# This reads an existing fit; it does not refit or assert a causal interpretation.
ss_decomposition <- function(fit) {
  if (!inherits(fit,"lm") || attr(terms(fit),"intercept") != 1L ||
      !is.null(fit$weights) || !is.null(model.offset(model.frame(fit))) || anyNA(coef(fit)))
    stop("Use a full-rank, unweighted lm with intercept and no offset.")
  y <- as.numeric(model.response(model.frame(fit))); yh <- as.numeric(fitted(fit))
  if (!length(y) || !all(is.finite(c(y,yh)))) stop("Non-finite fitted data.")
  mu <- mean(y); total <- y-mu; explained <- yh-mu; residual <- y-yh
  sst <- sum(total^2); ssr <- sum(explained^2); sse <- sum(residual^2)
  points <- data.frame(id=seq_along(y),observed=y,baseline=mu,fitted=yh,
    total=total,explained=explained,residual=residual,
    baseline_sq=total^2,residual_sq=residual^2,improvement=total^2-residual^2,
    cross_term=2*explained*residual)
  summary <- data.frame(n=length(y),parameters=fit$rank,df=df.residual(fit),
    SST=sst,SSR=ssr,SSE=sse,R2=if(sst>0) 1-sse/sst else NA_real_,
    sigma2=if(df.residual(fit)>0) sse/df.residual(fit) else NA_real_,
    cross_sum=sum(points$cross_term),decomposition_gap=sst-ssr-sse)
  list(points=points,summary=summary)
}

# Same complete rows in all nested models; returns model/n/parameters/df/SST/SSE/R2/sigma.
# Increasing training R2 is not evidence of better future prediction or causation.
compare_attitude_models <- function(data=datasets::attitude) {
  choices <- list(mean=character(0),one="complaints",two=c("complaints","privileges"),
    six=setdiff(names(datasets::attitude),"rating"))
  validate_numeric_frame(data,names(datasets::attitude))
  do.call(rbind,lapply(names(choices),function(key) {
    s <- ss_decomposition(fit_attitude(data,choices[[key]]))$summary
    data.frame(model=key,s[c("n","parameters","df","SST","SSE","R2")],sigma=sqrt(s$sigma2),row.names=NULL)
  }))
}

# Regress rating and target separately on controls (both with intercept), then residual on residual.
# Returns points (department/rx/ry), two nuisance fits, residual fit, full fit and slope.
# Example target='privileges', controls='complaints' -> slope approximately -0.0501598.
# 'Adjusted' means subtracting fitted linear components; it does not establish causality.
partial_regression <- function(data=datasets::attitude,target="privileges",controls="complaints") {
  allowed <- setdiff(names(datasets::attitude),"rating")
  if (length(target)!=1L || !target %in% allowed || !is.character(controls) ||
      !length(controls) || anyDuplicated(controls) || !all(controls %in% allowed) || target %in% controls)
    stop("Choose one target and distinct other control predictors.")
  full <- fit_attitude(data,c(controls,target))
  yfit <- lm(reformulate(controls,response="rating"),data=data)
  xfit <- lm(reformulate(controls,response=target),data=data)
  points <- data.frame(department=seq_len(nrow(data)),rx=as.numeric(resid(xfit)),ry=as.numeric(resid(yfit)))
  residual_fit <- lm(ry~rx,data=points)
  list(points=points,yfit=yfit,xfit=xfit,residual_fit=residual_fit,full=full,
    slope=unname(coef(residual_fit)["rx"]),target=target,controls=controls)
}

# New conditions in percentage points -> rows in the SAME input order, rating_hat numeric.
# This uses the two-predictor model, never refits it; finite [0,100] input is required.
# Range flag is univariate only; FALSE does not guarantee joint support or causal validity.
predict_conditions <- function(fit,complaints,privileges,data=datasets::attitude) {
  if (!inherits(fit,"lm") || !setequal(attr(terms(fit),"term.labels"),c("complaints","privileges")))
    stop("Use the complaints + privileges model.")
  if (!is.numeric(complaints) || !is.numeric(privileges) || length(complaints)!=length(privileges) ||
      !length(complaints) || !all(is.finite(c(complaints,privileges))) ||
      any(c(complaints,privileges)<0 | c(complaints,privileges)>100))
    stop("Two equal-length finite numeric percentage vectors in [0,100] are required.")
  nd <- data.frame(complaints=complaints,privileges=privileges)
  nd$rating_hat <- as.numeric(predict(fit,newdata=nd))
  nd$outside_observed_range <- complaints<min(data$complaints) | complaints>max(data$complaints) |
    privileges<min(data$privileges) | privileges>max(data$privileges)
  nd
}

# data x/y + candidate intercept/slope -> fitted/residual rows and scalar SSE.
# This evaluates chosen coefficients; it does NOT estimate them by optimization.
candidate_line <- function(data=four_points(),intercept=1,slope=1.2) {
  validate_numeric_frame(data,c("x","y"))
  if(length(intercept)!=1L || length(slope)!=1L || !all(is.finite(c(intercept,slope))))
    stop("Use finite scalar intercept and slope.")
  yh <- intercept+slope*data$x
  list(points=data.frame(data,fitted=yh,residual=data$y-yh),SSE=sum((data$y-yh)^2))
}

# Draw a mean-only or OLS prediction, with selected observation and signed deviations.
# mode 'mean' shows baseline error, 'fit' shows residual, 'three' also shows mean-to-fit.
# Returns the computed decomposition invisibly. Only plotting is a side effect.
plot_deviation_story <- function(selected=2L,mode=c("three","mean","fit")) {
  mode <- match.arg(mode); d <- four_points(); fit <- lm(y~x,data=d); s <- ss_decomposition(fit)
  if(length(selected)!=1L || !selected %in% 1:4) stop("Select observation 1,2,3 or 4.")
  plot(d$x,d$y,pch=19,cex=1.3,xlim=c(.6,4.5),ylim=c(1.2,6.6),xlab="x",ylab="y",main="Same observations, different predictions")
  abline(h=mean(d$y),col="#64748b",lwd=2,lty=2)
  if(mode!="mean") abline(fit,col="#087f8c",lwd=2)
  for(i in 1:4) segments(d$x[i],if(mode=="mean") mean(d$y) else fitted(fit)[i],d$x[i],d$y[i],col="#db6656",lwd=2)
  i <- as.integer(selected); points(d$x[i],d$y[i],pch=21,bg="#f2b544",cex=1.7)
  if(mode=="three") {
    segments(d$x[i]+.10,mean(d$y),d$x[i]+.10,fitted(fit)[i],col="#087f8c",lwd=4)
    segments(d$x[i]-.10,mean(d$y),d$x[i]-.10,d$y[i],col="#475569",lwd=4)
  }
  legend("topleft",c("Observed","Mean baseline","Regression prediction","Residual"),
    col=c("#111827","#64748b","#087f8c","#db6656"),pch=c(19,NA,NA,NA),lty=c(NA,2,1,1),bty="n",cex=.8)
  invisible(s)
}

# Plot the fitted two-variable model along complaints, at fixed privileges (percent).
# Points show raw observations with varying privileges; they need not lie on this slice.
plot_conditional_slice <- function(fit,privileges=50,data=datasets::attitude) {
  grid <- predict_conditions(fit,seq(min(data$complaints),max(data$complaints),length.out=100),rep(privileges,100),data)
  plot(data$complaints,data$rating,pch=19,col="#a9b5c3",xlab="Complaints (%)",ylab="Overall rating (%)",main=paste("Fitted slice: privileges =",privileges,"%"))
  lines(grid$complaints,grid$rating_hat,col="#087f8c",lwd=3)
  legend("topleft",c("Raw departments (other values vary)","Fixed-condition prediction"),col=c("#a9b5c3","#087f8c"),pch=c(19,NA),lty=c(NA,1),bty="n",cex=.8)
  invisible(grid)
}
