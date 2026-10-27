# W09B: use after diagnostics.R and diagnostics-influence.R.
# These are linear diagnostic coordinates, not causal-effect estimates.

diag_effect_variable <- function(fit, variable) {
  diag_validate_ols(fit)
  if (length(variable)!=1L || !is.character(variable) ||
      !variable %in% names(model.frame(fit))[-1L])
    stop("Select one existing numeric predictor by its exact name.")
  invisible(variable)
}

# Added-variable/partial-regression plot: residualize BOTH response and predictor
# against the SAME other predictors (including the intercept), on the SAME rows.
diag_added_variable <- function(fit, variable) {
  diag_effect_variable(fit, variable)
  X <- model.matrix(fit); y <- model.response(model.frame(fit))
  j <- match(variable,colnames(X)); Z <- X[,-j,drop=FALSE]
  qz <- qr(Z)
  rx <- as.numeric(qr.resid(qz,X[,j])); ry <- as.numeric(qr.resid(qz,y))
  denominator <- sum(rx^2)
  if (!is.finite(denominator) || denominator<=0) stop("No independent predictor variation remains.")
  list(variable=variable,coefficient=unname(coef(fit)[variable]),
       slope=sum(rx*ry)/denominator,
       data=data.frame(row=seq_along(y),x_residual=rx,y_residual=ry))
}

# Component+residual/partial-residual plot: RAW predictor against e + b_j*x_j.
# This x axis is different from the added-variable plot's residualized predictor.
diag_component_residual <- function(fit, variable) {
  diag_effect_variable(fit, variable)
  x <- model.frame(fit)[[variable]]; b <- unname(coef(fit)[variable])
  data.frame(row=seq_along(x),x=x,residual=as.numeric(residuals(fit)),
             component=b*x,component_residual=as.numeric(residuals(fit))+b*x)
}
