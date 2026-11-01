# W06A: unweighted full-rank OLS diagnostics. No packages or network calls.
# p = number of predictors; k = total coefficients; nu = n-k.
diag_validate_fit <- function(fit) {
  if (!inherits(fit,"lm") || inherits(fit,"mlm")) stop("A univariate lm fit is required.")
  if (!is.null(fit$weights) || !is.null(fit$offset)) stop("Use unweighted OLS without an offset.")
  X <- model.matrix(fit)
  if (fit$rank!=ncol(X)) stop("The design must have full column rank.")
  if (!is.null(fit$na.action)) stop("Resolve missing observations explicitly before this lesson.")
  if (df.residual(fit)<=1 || any(!is.finite(residuals(fit)))) stop("Finite observations and residual df > 1 are required.")
  if (!is.finite(deviance(fit)) || deviance(fit)<=.Machine$double.eps) stop("Residual variance must be positive.")
  invisible(fit)
}

# lm -> one row per observation. Raw units follow Y; internal/external are unitless.
# h=1 is explicitly undefined; these cases are not silently assigned zero.
diag_residuals <- function(fit) {
  diag_validate_fit(fit)
  e <- as.numeric(residuals(fit)); h <- as.numeric(hatvalues(fit))
  nu <- df.residual(fit); s <- sqrt(deviance(fit)/nu)
  ok <- 1-h>1e-10
  internal <- external <- s_deleted <- rep(NA_real_,length(e))
  internal[ok] <- e[ok]/(s*sqrt(1-h[ok]))
  v <- rep(NA_real_,length(e))
  v[ok] <- (deviance(fit)-e[ok]^2/(1-h[ok]))/(nu-1)
  deleted_ok <- ok & is.finite(v) & v>1e-12
  s_deleted[deleted_ok] <- sqrt(v[deleted_ok])
  external[deleted_ok] <- e[deleted_ok]/(s_deleted[deleted_ok]*sqrt(1-h[deleted_ok]))
  data.frame(row=seq_along(e),observed=as.numeric(model.response(model.frame(fit))),
    fitted=as.numeric(fitted(fit)),raw=e,h=h,s=s,s_deleted=s_deleted,
    internal=internal,external=external,
    status=ifelse(!ok,"h=1: standardized residual undefined",
      ifelse(!deleted_ok,"deleted variance is zero or numerically unstable","ok")))
}

# Official Hamilton data, canonical CSV supplied with the lesson. No generated replacements.
diag_hamilton <- function(path) {
  d <- read.csv(path,check.names=FALSE)
  if (!identical(names(d),c("Y","X1","X2")) || nrow(d)!=15 ||
      !all(vapply(d,is.numeric,logical(1))) || any(!is.finite(as.matrix(d))))
    stop("Expected the supplied Hamilton CSV: 15 finite rows, Y/X1/X2.")
  d
}

# Three comparable fits of the SAME response and SAME rows.
diag_hamilton_fits <- function(d) {
  fits <- list(X1=lm(Y~X1,data=d),X2=lm(Y~X2,data=d),both=lm(Y~X1+X2,data=d))
  data.frame(model=names(fits),R2=vapply(fits,function(f) summary(f)$r.squared,0.0),
    SSE=vapply(fits,deviance,0.0),rank=vapply(fits,function(f) f$rank,0L),row.names=NULL)
}

# Orthographic 3-D projection, AFTER z-scaling X1/X2/Y. Angles in degrees.
# d is not modified. Output columns are display coordinates, not original units.
diag_project <- function(d,azimuth=35,elevation=20) {
  if (length(azimuth)!=1 || length(elevation)!=1 || !all(is.finite(c(azimuth,elevation))))
    stop("Angles must be finite scalars.")
  Z <- as.matrix(d[c("X1","X2","Y")])
  if (any(!is.finite(Z)) || any(apply(Z,2,sd)<=0)) stop("Use three nonconstant finite numeric columns.")
  Z <- scale(Z); a <- azimuth*pi/180; b <- elevation*pi/180
  u <- cos(a)*Z[,1]+sin(a)*Z[,2]
  depth0 <- -sin(a)*Z[,1]+cos(a)*Z[,2]
  v <- cos(b)*Z[,3]-sin(b)*depth0
  depth <- sin(b)*Z[,3]+cos(b)*depth0
  data.frame(row=seq_len(nrow(d)),u=as.numeric(u),v=as.numeric(v),depth=as.numeric(depth))
}

# Explicitly simulated illustrations; collection order is meaningful here only.
# Same random innovations make the four scenarios comparable. RNG state restored.
diag_patterns <- function(n=100,seed=605) {
  if (length(n)!=1 || !is.finite(n) || n<20 || n!=as.integer(n)) stop("n must be an integer >= 20.")
  had <- exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  if (had) old <- get(".Random.seed",envir=.GlobalEnv)
  on.exit(if(had) assign(".Random.seed",old,envir=.GlobalEnv) else if(exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)) rm(".Random.seed",envir=.GlobalEnv))
  set.seed(seed); x <- seq(-2,2,length.out=n); z <- rnorm(n)
  means <- list(band=2+x,curve=2+x+1.3*x^2,fan=2+x,order=2+x)
  noise <- list(band=z,curve=.5*z,fan=(.2+.7*(x+2))*z,
    order=as.numeric(stats::filter(z,filter=.8,method="recursive")))
  lapply(names(means),function(name) {
    d <- data.frame(x=x,y=means[[name]]+noise[[name]],order=seq_len(n))
    f <- lm(y~x,data=d)
    data.frame(kind=name,d,fitted=as.numeric(fitted(f)),residual=as.numeric(residuals(f)))
  }) |> setNames(names(means))
}
