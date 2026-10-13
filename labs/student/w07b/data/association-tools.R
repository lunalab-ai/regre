# W03A association tools. Base R only; no downloads, fitting or global mutation.
# Public source after reviewed release: src/association-tools.R

# association_summary(x, y)
# x,y: finite numeric vectors of equal length >=2; pairs retain their row order.
# Returns one-row data.frame: n, mean_x, mean_y, sd_x, sd_y, covariance,
# correlation, correlation_defined. Means/SD retain input units; covariance has
# product units; Pearson correlation is unitless. Uses sample denominator n-1.
# Constant input: correlation=NA_real_, correlation_defined=FALSE (undefined).
# Example: association_summary(c(1,2,3,4),c(2,4,4,6)) -> cov2, r0.9486833.
association_summary <- function(x, y) {
  stopifnot(is.numeric(x), is.numeric(y), length(x) == length(y),
            length(x) >= 2, all(is.finite(x)), all(is.finite(y)))
  sx <- sd(x); sy <- sd(y)
  defined <- sx > 0 && sy > 0
  data.frame(n=length(x), mean_x=mean(x), mean_y=mean(y), sd_x=sx, sd_y=sy,
             covariance=cov(x,y), correlation=if (defined) cor(x,y) else NA_real_,
             correlation_defined=defined)
}

# association_data(repair, dataset="repair", time_unit="minutes")
# repair: data.frame with numeric Units and Minutes, one row per repair record.
# dataset: "repair", "curve", "anscombe1" ... "anscombe4".
# time_unit: "minutes" or "seconds"; changes Y only for the repair dataset.
# Returns data.frame X,Y. Repair row order is preserved; curve has X=-2:2;
# Anscombe rows follow datasets::anscombe. Does not change repair or fit a model.
# Example: association_data(repair,"repair","seconds")$Y == 60*repair$Minutes.
association_data <- function(repair, dataset="repair", time_unit="minutes") {
  stopifnot(dataset %in% c("repair","curve",paste0("anscombe",1:4)),
            time_unit %in% c("minutes","seconds"))
  if (dataset == "curve") return(data.frame(X=-2:2,Y=(-2:2)^2))
  if (startsWith(dataset,"anscombe")) {
    k <- as.integer(sub("anscombe","",dataset))
    return(data.frame(X=datasets::anscombe[[paste0("x",k)]],
                      Y=datasets::anscombe[[paste0("y",k)]]))
  }
  stopifnot(all(c("Units","Minutes") %in% names(repair)),
            is.numeric(repair$Units),is.numeric(repair$Minutes))
  data.frame(X=repair$Units, Y=repair$Minutes * if(time_unit=="seconds") 60 else 1)
}
