# W10B public explanation examples; independent exercises remain incomplete.
# Prefer bundled files; otherwise download from one fixed public tag.
tag <- "2026-fall-w10b"
local_dirs <- c("data","labs/student/w10b/data","../../labs/student/w10b/data",
                "../../../labs/student/w10b/data","../data")
found <- local_dirs[file.exists(file.path(local_dirs,"diagnostics-w10b.R"))]
cache_root <- Sys.getenv("REGRE_CACHE_DIR",unset=file.path(path.expand("~"),".cache","regre"))
data_dir <- if(length(found)) found[1] else file.path(cache_root,tag)
dir.create(data_dir,recursive=TRUE,showWarnings=FALSE)
expected <- c("diagnostics-base-w10b.R"="1d6d198179eb52922e0b7da3a3836838","diagnostics-influence-w10b.R"="106f87499e0a0565f4c19d75b7e26c9a","diagnostics-effects-w10b.R"="df333742f83c7f635427673c62acf214","diagnostics-w10b.R"="bf0d09021d75d1e04dbbbfc64fd23403","hand-five-w10b.csv"="d5911a65bf38d08ef947d43cb7ebf0e9","nyrivers-w10b.csv"="6f67635643fbb5aac0b37b7a8fed0d26","scottish-hills-w10b.csv"="ea6e5b9206884d205cfa393d89e0f84a")
options(timeout=120)
for(name in names(expected)) {
 target <- file.path(data_dir,name)
 if(!file.exists(target)) {
  url <- paste0("https://raw.githubusercontent.com/lunalab-ai/regre/",tag,"/labs/student/w10b/data/",name)
  status <- download.file(url,target,mode="wb")
  if(status!=0) stop("Download failed. Check the connection and rerun preparation.")
  cat(name,": fixed-tag download\n")
 } else cat(name,": bundled/cache file\n")
 if(unname(tools::md5sum(target))!=expected[[name]])
  stop("Unexpected file bytes. Preserve edited files; use a fresh folder or cache.")
}
source(file.path(data_dir,"diagnostics-base-w10b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-influence-w10b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-effects-w10b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-w10b.R"),encoding="UTF-8")
toy <- read.csv(file.path(data_dir,"hand-five-w10b.csv"))
ny <- read.csv(file.path(data_dir,"nyrivers-w10b.csv"))
hills <- read.csv(file.path(data_dir,"scottish-hills-w10b.csv"))
ft <- lm(y~x,toy); fn <- lm(Nitrogen~ComIndl,ny)
fh <- lm(Time~Distance+Climb,hills)
stopifnot(nrow(toy)==5,nrow(ny)==20,nrow(hills)==35,hills$Time[23]==2859)
cat("W10B_DATA_READY: toy5 / NY20 / Hills35; units unchanged\n")

# E01 · 관측과 적합값을 따로 읽기
print(c(observed=toy$y[3],fitted=fitted(ft)[3],residual=residuals(ft)[3],h=hatvalues(ft)[3]))
plot(toy$x,toy$y,pch=19,xlab="x (teaching units)",ylab="y (teaching units)");abline(ft,col="steelblue",lwd=2)

# E02–E03 · 제외 후 모든 원래 위치에서 비교
d4 <- w10b_deletion_trace(ft,4)
print(d4$predictions,digits=6)
print(c(numerator=d4$numerator,denominator=d4$denominator,Cook=d4$Cook_from_predictions))

# E04 · 자기 위치와 삭제 규모
print(d4$score[,c("row","h","raw","Cook","DFFITS")],digits=6)
print(c(full_s=d4$s,deleted_s=d4$s_deleted))

# E05 · 교재 NY의 P-R
ni <- diag_influence(fn)
print(ni[c(4,5),c("row","h","Cook","DFFITS","potential","residual_component","Hadi")],digits=6)
plot(ni$residual_component,ni$potential,pch=19,xlab="Hadi residual component R",ylab="Potential P");text(ni$residual_component,ni$potential,labels=ni$row,pos=3,cex=.7)

# E06-1 · 고도상승으로 시간 예측
aux_time <- lm(Time~Climb,hills)
print(c(observed=hills$Time[1],auxiliary=fitted(aux_time)[1],difference=residuals(aux_time)[1]))

# E06-2 · 같은 고도상승으로 거리도 예측
aux_distance <- lm(Distance~Climb,hills)
print(c(observed=hills$Distance[1],auxiliary=fitted(aux_distance)[1],difference=residuals(aux_distance)[1]))

# E06-3 · 두 잔차를 AV로 연결
ef <- w10b_effect_trace(fh,"Distance")
print(ef$data[1,c("row","x","observed","auxiliary_x","auxiliary_y","av_x","av_y")],digits=6)
print(c(AV_slope=ef$av_slope,full_model_coefficient=coef(fh)["Distance"]))
plot(ef$data$av_x,ef$data$av_y,pch=19,xlab="Distance residual (miles)",ylab="Time residual (seconds)");abline(0,ef$av_slope,col="steelblue",lwd=2)

# E07 · 전체 잔차와 거리 성분
cp <- diag_component_residual(fh,"Distance")
print(ef$data[1,c("row","fitted","residual","component","cpr_x","cpr_y")],digits=6)
plot(cp$x,cp$component_residual,pch=19,xlab="Original Distance (miles)",ylab="Component + residual (seconds)");abline(0,coef(fh)["Distance"],col="steelblue",lwd=2)

# 변수 추가의 두 질문
distance_only <- lm(Time~Distance,hills)
print(c(distance_only=coef(distance_only)["Distance"],with_Climb=coef(fh)["Distance"]))
print(summary(fh)$coefficients["Climb",])

# E08 · Huber의 잔차 가중치와 실제 한계
print(w10b_huber_trace(c(.5,2,4)))
if(!requireNamespace("MASS",quietly=TRUE)) stop("Use R with recommended MASS or the installation-free online R route.")
rob <- MASS::rlm(Time~Distance+Climb,hills,maxit=100)
print(list(converged=rob$converged,df_residual=rob$df.residual))
print(data.frame(row=c(7,11,18),h=hatvalues(fh)[c(7,11,18)],weight=rob$w[c(7,11,18)]))

# L01
my_L01_prediction <- NA_real_
my_L01_residual <- NA_real_
my_L01_h <- NA_real_

# L02
my_L02_Cook <- NA_real_
my_L02_DFFITS <- NA_real_
my_L02_reason <- ""

# L03
my_L03_P <- NA_real_
my_L03_R <- NA_real_
my_L03_H <- NA_real_

# L04
my_L04_x <- NA_real_
my_L04_y <- NA_real_
my_L04_interpretation <- ""

# L05
my_L05_CPR_x <- NA_real_
my_L05_CPR_y <- NA_real_
my_L05_weights <- rep(NA_real_,3)

# L06
my_L06_prediction <- ""
my_L06_saved_files <- ""
my_L06_restart_observation <- ""

# L07
my_L07_prediction <- ""

# L08
my_L08_coordinate <- c(NA_real_,NA_real_)

# L09
my_L09_ratio <- NA_real_
my_L09_explanation <- ""

# L10
my_L10_weight <- NA_real_
my_L10_convergence_check <- ""
stopifnot(nrow(toy)==5,nrow(ny)==20,nrow(hills)==35,
 abs(d4$Cook_from_predictions-cooks.distance(ft)[4])<1e-10,
 max(abs(ni$Cook-cooks.distance(fn)))<1e-9,
 abs(sum(hatvalues(ft))-2)<1e-10)
cat("W10B_INFLUENCE_RUNTIME_CHECK_PASSED\n")
stopifnot(nrow(hills)==35,hills$Time[23]==2859,
 abs(ef$av_slope-coef(fh)["Distance"])<1e-8,
 max(abs(cp$component_residual-(residuals(fh)+coef(fh)["Distance"]*hills$Distance)))<1e-8,
 rob$converged,is.na(rob$df.residual),abs(rob$w[11]-1)<1e-8)
cat("W10B_EFFECTS_RUNTIME_CHECK_PASSED\n")
