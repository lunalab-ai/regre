# W05B reusable multiple-regression inference helpers (base R only).
# Units follow input data; attitude changes are percentage points.
# No download, installation, or mutation of user data. See mlr-inference-api.md.

# Internal contract: full-rank, unweighted, no-offset OLS with positive df.
mlr_validate_fit <- function(fit) {
  if (!inherits(fit, "lm") || inherits(fit, "glm")) stop("Supply an lm fit.")
  X <- model.matrix(fit)
  if (!is.null(fit$weights) || !is.null(fit$offset)) stop("Use unweighted OLS without offsets.")
  if (fit$rank != ncol(X) || df.residual(fit) <= 0 || anyNA(coef(fit)))
    stop("Need full column rank and positive residual degrees of freedom.")
  if (any(!is.finite(X)) || any(!is.finite(model.response(model.frame(fit)))))
    stop("Use finite numeric observations.")
  invisible(fit)
}

# mlr_coefficient_table(fit, level=.95, null=0): lm -> coefficient-order table.
# null is one number (recycled) or one per coefficient. No model refit.
# Returns term, estimate, SE, df, null, t, p, lower, upper. Exact t needs Gaussian errors.
# Example: mlr_coefficient_table(lm(rating~complaints+learning, attitude)).
mlr_coefficient_table <- function(fit, level=.95, null=0) {
  mlr_validate_fit(fit)
  b <- coef(fit); k <- length(b)
  if (length(level)!=1 || !is.finite(level) || level<=0 || level>=1) stop("level must be between 0 and 1.")
  if (!length(null) %in% c(1L,k) || any(!is.finite(null))) stop("null must be scalar or coefficient-length.")
  null <- rep(null,length.out=k); se <- sqrt(diag(vcov(fit))); df <- df.residual(fit)
  if (any(se<=0)) stop("Positive coefficient standard errors are required.")
  t <- (b-null)/se; critical <- qt((1+level)/2,df)
  data.frame(term=names(b),estimate=unname(b),SE=unname(se),df=df,null=null,
             t=unname(t),p=2*pt(-abs(t),df),lower=unname(b-critical*se),upper=unname(b+critical*se),row.names=NULL)
}

# mlr_nested_f(reduced, full): two lm objects -> one-row partial F table.
# Requires identical response/row order and nesting of design-column spaces.
# Returns q, df_full, SSE_reduced, SSE_full, extra_SS, F, p. No refitting.
# Example: mlr_nested_f(lm(rating~complaints+learning,attitude),lm(rating~.,attitude)).
mlr_nested_f <- function(reduced, full) {
  mlr_validate_fit(reduced); mlr_validate_fit(full)
  mr <- model.frame(reduced); mf <- model.frame(full)
  if (!identical(rownames(mr),rownames(mf)) ||
      !isTRUE(all.equal(as.numeric(model.response(mr)),as.numeric(model.response(mf)),tolerance=1e-12)))
    stop("Both models must use the identical response and observation rows in the same order.")
  xr <- model.matrix(reduced); xf <- model.matrix(full)
  if (max(abs(qr.resid(qr(xf),xr))) > 1e-8*max(1,max(abs(xr)))) stop("Models are not nested.")
  q <- full$rank-reduced$rank; df <- df.residual(full)
  if (q<1) stop("Full model must add at least one independent coefficient.")
  sser <- deviance(reduced); ssef <- deviance(full)
  if (ssef<=0) stop("Positive residual variation is required.")
  extra <- sser-ssef
  if (extra < -1e-8*max(1,sser)) stop("Inconsistent sums of squares.")
  F <- max(0,extra)/q/(ssef/df)
  data.frame(q=q,df_full=df,SSE_reduced=sser,SSE_full=ssef,extra_SS=extra,F=F,p=pf(F,q,df,lower.tail=FALSE))
}

# mlr_linear_test(fit,L,r=0): test L beta=r. L columns MUST match coef(fit) order.
# L: numeric q by k full-row-rank matrix, r: scalar or q-vector.
# Returns q, df_full, F, p. Includes coefficient covariance, unlike summing SEs.
# Example (two-predictor fit): L=matrix(c(0,1,-1),nrow=1) tests equal slopes.
mlr_linear_test <- function(fit, L, r=0) {
  mlr_validate_fit(fit)
  if (is.null(dim(L))) L <- matrix(L,nrow=1)
  if (!is.numeric(L) || ncol(L)!=length(coef(fit)) || any(!is.finite(L)) ||
      nrow(L)<1 || qr(t(L))$rank != nrow(L)) stop("L needs independent rows and one column per coefficient.")
  q <- nrow(L)
  if (!length(r) %in% c(1L,q) || any(!is.finite(r))) stop("r must be scalar or one value per restriction.")
  delta <- as.vector(L%*%coef(fit))-rep(r,length.out=q)
  V <- L%*%vcov(fit)%*%t(L)
  F <- as.numeric(crossprod(delta,solve(V,delta)))/q; df <- df.residual(fit)
  data.frame(q=q,df_full=df,F=F,p=pf(F,q,df,lower.tail=FALSE))
}

# mlr_interval_comparison(fit,newdata,level=.95,noise_multiplier=1): two rows per new case.
# newdata uses ORIGINAL training units and matching predictor names.
# Returns case, kind, fit, lower, upper, width, h0, level, noise_multiplier.
# Multiplier=1 reproduces predict.lm; other positive values are a WHAT-IF error-scale scenario.
# No refit. CI targets mean response; PI targets one independent future observation.
mlr_interval_comparison <- function(fit, newdata, level=.95, noise_multiplier=1) {
  mlr_validate_fit(fit)
  if (!is.data.frame(newdata) || !nrow(newdata)) stop("newdata must be a nonempty data.frame.")
  if (length(level)!=1 || !is.finite(level) || level<=0 || level>=1) stop("Invalid confidence level.")
  if (length(noise_multiplier)!=1 || !is.finite(noise_multiplier) || noise_multiplier<=0) stop("Positive noise multiplier required.")
  prediction <- predict(fit,newdata=newdata,se.fit=TRUE)
  if (any(!is.finite(prediction$fit)) || any(!is.finite(prediction$se.fit))) stop("Finite predictions required.")
  s <- sigma(fit)
  if (s<=0) stop("Positive estimated error scale required.")
  h0 <- as.vector(prediction$se.fit^2/s^2)
  critical <- qt((1+level)/2,df.residual(fit))
  do.call(rbind,lapply(seq_len(nrow(newdata)),function(i) {
    se <- noise_multiplier*s*sqrt(c(h0[i],1+h0[i]))
    margin <- critical*se
    data.frame(case=i,kind=c("confidence","prediction"),fit=as.numeric(prediction$fit[i]),
               lower=as.numeric(prediction$fit[i])-margin,upper=as.numeric(prediction$fit[i])+margin,
               width=2*margin,h0=h0[i],level=level,noise_multiplier=noise_multiplier)
  }))
}

# mlr_scaling(data=attitude): numeric rating/complaints/learning table -> named list.
# Fits four intercept models: original, centered X, z-scored X/Y, unit-length X/Y.
# Returns models, coefficient table, original-unit fitted values, training center/scale.
# Does not alter input. Zero-variance columns are rejected; training transforms are retained.
mlr_scaling <- function(data=datasets::attitude) {
  columns <- c("rating","complaints","learning")
  if (!is.data.frame(data) || !all(columns %in% names(data))) stop("Need rating, complaints and learning columns.")
  d <- data[columns]
  if (nrow(d)<4 || !all(vapply(d,is.numeric,logical(1))) || any(!is.finite(as.matrix(d)))) stop("Need at least four complete numeric rows.")
  centers <- vapply(d,mean,numeric(1)); scales <- vapply(d,sd,numeric(1))
  if (any(scales<=0)) stop("Cannot scale a constant column.")
  centered <- d
  centered[c("complaints","learning")] <- sweep(as.matrix(d[c("complaints","learning")]),2,centers[c("complaints","learning")],"-")
  z <- as.data.frame(scale(d,center=centers,scale=scales))
  norms <- scales*sqrt(nrow(d)-1)
  unit <- as.data.frame(scale(d,center=centers,scale=norms))
  models <- lapply(list(original=d,centered=centered,standardized=z,unit_length=unit),function(x) lm(rating~complaints+learning,data=x))
  invisible(lapply(models,mlr_validate_fit))
  coefficients <- do.call(rbind,lapply(names(models),function(k) {
    b <- coef(models[[k]])
    data.frame(method=k,intercept=unname(b[1]),complaints=unname(b[2]),learning=unname(b[3]))
  }))
  restored <- data.frame(original=fitted(models$original),centered=fitted(models$centered),
                         standardized=centers['rating']+scales['rating']*fitted(models$standardized),
                         unit_length=centers['rating']+norms['rating']*fitted(models$unit_length))
  list(models=models,coefficients=coefficients,fitted_original_units=restored,
       centers=centers,scales=scales,norms=norms,standardized=z,unit_length=unit)
}

# mlr_simulate(B=1000,sigma_error=7,seed=730): synthetic fixed-design experiment.
# X is attitude's complaints/learning; true beta=(10,.65,.20); errors iid normal.
# Returns B coefficient draws and theoretical/empirical spread; local RNG state is restored.
# No resampling of actual rating; this is simulation, not new survey data.
mlr_simulate <- function(B=1000,sigma_error=7,seed=730) {
  if (length(B)!=1 || !is.finite(B) || B<2 || B>10000 || B!=as.integer(B)) stop("B must be an integer from 2 to 10000.")
  if (length(sigma_error)!=1 || !is.finite(sigma_error) || sigma_error<=0) stop("Positive sigma_error required.")
  if (length(seed)!=1 || !is.finite(seed)) stop("Supply one finite seed.")
  had_seed <- exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  if (had_seed) old_seed <- get(".Random.seed",envir=.GlobalEnv)
  on.exit(if(had_seed) assign(".Random.seed",old_seed,envir=.GlobalEnv) else if(exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)) rm(".Random.seed",envir=.GlobalEnv))
  set.seed(seed)
  X <- model.matrix(~complaints+learning,data=datasets::attitude)
  truth <- c(10,.65,.20); names(truth) <- colnames(X)
  Y <- as.vector(X%*%truth)+matrix(rnorm(nrow(X)*B,sd=sigma_error),nrow=nrow(X))
  estimates <- t(qr.coef(qr(X),Y))
  theoretical <- sigma_error*sqrt(diag(solve(crossprod(X))))
  list(draws=as.data.frame(estimates),summary=data.frame(term=names(truth),truth=truth,
       mean=colMeans(estimates),empirical_SD=apply(estimates,2,sd),theoretical_SD=theoretical,row.names=NULL),
       B=B,sigma_error=sigma_error,seed=seed)
}
