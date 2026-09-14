# W03A: Open this script from the extracted w03a folder, or use the browser R page.
# Data and shared functions are bundled. No installation or download is needed.
# Full guided explanations and the four exercises are in the companion QMD.
locations <- c("data", "../../labs/student/w03a/data", "labs/student/w03a/data")
data_dir <- locations[file.exists(file.path(locations,"association-tools.R"))][1]
stopifnot(!is.na(data_dir))
source(file.path(data_dir,"association-tools.R"))
repair <- read.table(file.path(data_dir,"Computer.Repair.txt"),header=TRUE)

# One pair per row; numeric X=parts, Y=minutes. source() loads functions, not a model.
x <- c(1,2,3,4); y <- c(2,4,4,6)
small_summary <- association_summary(x,y)
print(small_summary)
plot(x,y,pch=19,xlab="X",ylab="Y")
abline(v=mean(x),h=mean(y),lty=2)

# L1: Define seconds_try from repair$Minutes, then compare cov and cor.
# Keep your exercise variable separate so later examples remain runnable.
# seconds_try <- ...

# Each row remains a matched Units/Minutes pair. No missing values here.
repair_summary <- association_summary(repair$Units,repair$Minutes)
print(repair_summary)
plot(repair$Units,repair$Minutes,pch=19,xlab="Units",ylab="Minutes")
abline(v=mean(repair$Units),h=mean(repair$Minutes),lty=2)

# L2: mean(x*y) is NOT sample covariance. Explain and correct its formula.
# covariance_try <- ...

curve_data <- association_data(repair,"curve")
curve_summary <- association_summary(curve_data$X,curve_data$Y)
print(curve_summary)
plot(curve_data$X,curve_data$Y,pch=19,xlab="X",ylab="Y = X^2")
# L3: Explain why a zero correlation here does not mean no relationship.

# Compare all four patterns on matching axes. The loop changes data, not a model.
old_par <- par(mfrow=c(2,2))
for (k in 1:4) {
  d <- association_data(repair,paste0("anscombe",k))
  plot(d$X,d$Y,pch=19,xlim=c(3,20),ylim=c(2,14),xlab="X",ylab="Y",
       main=paste("Set",k,"r =",round(cor(d$X,d$Y),4)))
}
par(old_par)
# L4: In app/app.R, locate time_unit -> association_current -> summary/plot.
# Change the default unit selection, rerun the app, and describe the outputs.

stopifnot(nrow(repair)==14, nrow(small_summary)==1,
          abs(small_summary$covariance-2)<1e-10,
          abs(repair_summary$correlation-0.9936987461308753)<1e-10,
          abs(curve_summary$correlation)<1e-10)
