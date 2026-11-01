# W07B: base-R teaching helpers. Explicit baselines; no network or input mutation.
review_fit_data <- function() {
  data.frame(Units=1:5,Minutes=c(3,6,7,8,11))
}
review_fit_components <- function(x,y,mode=c("intercept","origin","mean")) {
  mode <- match.arg(mode)
  if(!is.numeric(x)||!is.numeric(y)||length(x)!=length(y)||length(y)<3L||
     any(!is.finite(x))||any(!is.finite(y))) stop("finite paired numeric vectors, n >= 3 required")
  if(mode!="mean" && (sum(x*x)==0 || (mode=="intercept" && var(x)==0))) stop("full-rank X required")
  d <- data.frame(Units=x,Minutes=y)
  form <- switch(mode,intercept=Minutes~Units,origin=Minutes~0+Units,mean=Minutes~1)
  model <- lm(form,data=d)
  pred <- unname(fitted(model));e <- unname(residuals(model));a <- pred-mean(y)
  sse <- sum(e^2);sst <- sum((y-mean(y))^2)
  den <- if(mode=="origin") sum(y^2) else sst
  list(model=model,mode=mode,rows=data.frame(x=x,y=y,fitted=pred,total=y-mean(y),explained=a,residual=e),
       SSE=sse,SST=sst,SSR=sum(a*a),cross=2*sum(a*e),df=df.residual(model),
       R2=if(den>0) 1-sse/den else NA_real_,baseline=if(mode=="origin") "zero" else "mean",
       R2_centered=if(sst>0) 1-sse/sst else NA_real_)
}
review_fit_intervals <- function(x,y,x0,level=.95) {
  z <- review_fit_components(x,y,"intercept")
  if(!is.numeric(x0)||!length(x0)||any(!is.finite(x0))) stop("finite x0 required")
  if(length(level)!=1||!is.numeric(level)||!is.finite(level)||level<=0||level>=1) stop("0 < level < 1 required")
  if(z$SSE<=.Machine$double.eps*max(1,sum(y*y))) stop("positive residual variance required")
  m <- z$model
  ci <- predict(m,newdata=data.frame(Units=x0),interval="confidence",level=level)
  pi <- predict(m,newdata=data.frame(Units=x0),interval="prediction",level=level)
  data.frame(x0=x0,fit=ci[,1],mean_lower=ci[,2],mean_upper=ci[,3],
             prediction_lower=pi[,2],prediction_upper=pi[,3],
             extrapolation=x0<min(x)|x0>max(x))
}
