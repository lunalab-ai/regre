# W07A reusable simple-regression calculations. Base R only.
# The example data are synthetic; they are not exercise answers.

# Return a five-row synthetic teaching dataset (x: tasks, y: minutes).
review_slr_data <- function() {
  data.frame(id=paste0("D",1:5),x=1:5,y=c(3,6,7,8,11))
}

# Summarize paired observations and classical OLS coefficient inference.
# x,y: finite numeric paired vectors. level: confidence level in (0,1).
# null: null slope in y/x units. Returns components, fit, residuals and CI.
review_slr <- function(x,y,level=.95,null=0) {
  if(!is.numeric(x)||!is.numeric(y)||length(x)!=length(y)||
     length(x)<3||any(!is.finite(x))||any(!is.finite(y)))
    stop("Use at least three finite, paired numeric observations.")
  if(length(level)!=1||!is.finite(level)||level<=0||level>=1||
     length(null)!=1||!is.finite(null)) stop("Invalid level or null slope.")
  n<-length(x);dx<-x-mean(x);dy<-y-mean(y)
  Sxx<-sum(dx^2);Syy<-sum(dy^2);Sxy<-sum(dx*dy)
  if(Sxx<=0) stop("The explanatory variable needs positive variation.")
  b1<-Sxy/Sxx;b0<-mean(y)-b1*mean(x)
  fitted<-b0+b1*x;residual<-y-fitted;SSE<-sum(residual^2)
  s<-sqrt(SSE/(n-2));se<-s/sqrt(Sxx)
  regular<-se>sqrt(.Machine$double.eps)*max(1,abs(b1))
  critical<-qt((1+level)/2,n-2)
  t_value<-if(regular) (b1-null)/se else NA_real_
  list(n=n,mean_x=mean(x),mean_y=mean(y),dx=dx,dy=dy,
    Sxx=Sxx,Syy=Syy,Sxy=Sxy,covariance=Sxy/(n-1),
    correlation=if(Syy>0) Sxy/sqrt(Sxx*Syy) else NA_real_,
    b0=b0,b1=b1,fitted=fitted,residual=residual,SSE=SSE,df=n-2,
    s=s,se_b1=se,se_b0=s*sqrt(1/n+mean(x)^2/Sxx),
    t=t_value,p=if(regular) 2*pt(-abs(t_value),n-2) else NA_real_,
    level=level,critical=critical,
    ci=if(regular) b1+c(-1,1)*critical*se else c(NA_real_,NA_real_),
    inference_available=regular)
}

# Return row-wise vertical residuals for a proposed line; does not refit OLS.
review_line <- function(x,y,intercept,slope) {
  if(!is.numeric(x)||!is.numeric(y)||length(x)!=length(y)||!length(x)||
     any(!is.finite(x))||any(!is.finite(y))||length(intercept)!=1||
     length(slope)!=1||!is.finite(intercept)||!is.finite(slope))
    stop("Supply finite paired data and one intercept/slope.")
  fitted<-intercept+slope*x
  data.frame(x=x,y=y,fitted=fitted,residual=y-fitted,squared=(y-fitted)^2)
}
