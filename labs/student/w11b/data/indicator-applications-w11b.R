# Inspectable indicator-variable applications. Base R; no I/O or silent row removal.
# All functions preserve source_row. Dataset units remain those of the source.

# Complete data.frame -> a copy with stable, unique row identities.
ia_rows <- function(data, columns) {
  if (!is.data.frame(data) || nrow(data)<2L || !all(columns %in% names(data)))
    stop("Supply a data.frame containing all required columns.")
  if (anyNA(data[columns])) stop("Resolve missing source values explicitly before fitting.")
  d <- data
  if (!"source_row" %in% names(d)) d$source_row <- seq_len(nrow(d))
  if (anyNA(d$source_row) || anyDuplicated(d$source_row)) stop("source_row must be complete and unique.")
  rownames(d) <- as.character(d$source_row)
  d
}

# Finite numeric y + nonempty group labels -> within/between/total sums of squares.
# rows: observed, group_mean, residual, squared; summary: n,k,SST,SSB,SSE,df,F,p.
ia_mean_parts <- function(y, group) {
  if (!is.numeric(y) || any(!is.finite(y)) || length(y)!=length(group) ||
      anyNA(group) || any(!nzchar(as.character(group)))) stop("Use complete numeric y and group labels.")
  g <- droplevels(factor(group)); n <- length(y); k <- nlevels(g)
  if (k<2L || n<=k) stop("Need at least two groups and positive within-group degrees of freedom.")
  grand <- mean(y)
  fitted <- ave(y,g,FUN=mean)
  residual <- y-fitted
  SSE <- sum(residual^2)
  SSB <- sum((fitted-grand)^2)
  SST <- sum((y-grand)^2)
  if (SSE<=0) stop("The classical F ratio needs positive within-group variation.")
  F <- (SSB/(k-1L))/(SSE/(n-k))
  list(rows=data.frame(observed=y,group=g,group_mean=fitted,residual=residual,squared=residual^2),
    summary=data.frame(n=n,k=k,grand=grand,SST=SST,SSB=SSB,SSE=SSE,
      q=k-1L,df=n-k,F=F,p=pf(F,k-1L,n-k,lower.tail=FALSE)))
}

# Original Date/Sales/PDI rows -> explicit Q4 (default) treatment coding.
# Parse each Date; never infer a quarter from row position or numeric factor codes.
ia_quarter_prepare <- function(data, reference=4L) {
  d <- ia_rows(data,c("Date","Sales","PDI"))
  d$Date <- trimws(as.character(d$Date))
  if (any(!grepl("^Q[1-4]/[0-9]{2}$",d$Date)) || anyDuplicated(d$Date) ||
      !is.numeric(d$Sales) || !is.numeric(d$PDI) || any(!is.finite(c(d$Sales,d$PDI))))
    stop("Use unique Q1/64-style dates and finite numeric Sales/PDI.")
  if (length(reference)!=1L || !reference %in% 1:4) stop("Choose one reference quarter from 1:4.")
  d$QuarterNumber <- as.integer(substr(d$Date,2,2))
  d$Year <- 1900L+as.integer(substr(d$Date,4,5))
  if (!setequal(unique(d$QuarterNumber),1:4)) stop("This four-quarter comparison needs all quarters.")
  d$Quarter <- factor(d$QuarterNumber,levels=c(reference,setdiff(1:4,reference)))
  contrasts(d$Quarter) <- contr.treatment(levels(d$Quarter),base=1)
  d
}

# Original STATE/Y/X1/X2/X3/Year rows -> 1975 baseline, two year indicators.
# Y and X1 use original monetary scales; X2/X3 are people per 1000.
ia_year_prepare <- function(data, reference=1975L) {
  d <- ia_rows(data,c("STATE","Y","X1","X2","X3","Year"))
  nums <- c("Y","X1","X2","X3","Year")
  if (!all(vapply(d[nums],is.numeric,logical(1))) || any(!is.finite(as.matrix(d[nums]))))
    stop("Use complete finite numeric Y/X1/X2/X3/Year.")
  d$STATE <- trimws(as.character(d$STATE))
  years <- c(1960L,1970L,1975L)
  if (any(!nzchar(d$STATE)) || anyDuplicated(paste(d$STATE,d$Year)) ||
      !setequal(unique(d$Year),years)) stop("Need unique STATE-Year keys for 1960/1970/1975.")
  if (length(reference)!=1L || !reference %in% years) stop("Choose a source year as reference.")
  d$YearGroup <- factor(d$Year,levels=c(reference,setdiff(years,reference)))
  contrasts(d$YearGroup) <- contr.treatment(levels(d$YearGroup),base=1)
  d
}

# EDIT THIS BODY: * allows both intercept and slope differences; + does not.
ia_full_formula <- function() {
  Y ~ (X1 + X2 + X3) * YearGroup
}

# Prepared year data + actual editable formula function -> same-row nested models.
# No source() call here: the function object supplied by the learner is used as-is.
ia_year_models <- function(data, formula_fn=ia_full_formula) {
  if (!is.function(formula_fn)) stop("formula_fn must be the actual function you edited.")
  d <- ia_rows(data,c("Y","X1","X2","X3","YearGroup"))
  if (!is.factor(d$YearGroup)) stop("Use prepared categorical YearGroup.")
  models <- list(common=lm(Y~X1+X2+X3,d,na.action=na.fail),
    intercept=lm(Y~X1+X2+X3+YearGroup,d,na.action=na.fail),
    full=lm(formula_fn(),d,na.action=na.fail))
  invisible(lapply(models,cat_check_fit))
  cat_check_pair(models$common,models$full)
  models
}
