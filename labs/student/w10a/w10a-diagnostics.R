# W10A public worked examples; independent exercises stay TODO.
# Fixed-tag, byte-verified preparation. Prefer the bundled data directory.
# No package installation, API key, account or manual upload is required.
tag <- "2026-fall-w10a"
local_dirs <- c("data","labs/student/w10a/data","../../labs/student/w10a/data","../../../labs/student/w10a/data")
found <- local_dirs[file.exists(file.path(local_dirs,"diagnostics-learning.R"))]
cache_root <- Sys.getenv("REGRE_CACHE_DIR",unset=file.path(path.expand("~"),".cache","regre"))
data_dir <- if(length(found)) found[1] else file.path(cache_root,tag)
dir.create(data_dir,recursive=TRUE,showWarnings=FALSE)
expected <- c("diagnostics-base-w09b.R"="1d6d198179eb52922e0b7da3a3836838","diagnostics-influence.R"="106f87499e0a0565f4c19d75b7e26c9a","diagnostics-effects.R"="df333742f83c7f635427673c62acf214","diagnostics-learning.R"="7ba534cc7178c9c6bbfde87f650926ca","hand-five-w10a.csv"="d5911a65bf38d08ef947d43cb7ebf0e9","nyrivers-w10a.csv"="6f67635643fbb5aac0b37b7a8fed0d26","scottish-hills-w10a.csv"="ea6e5b9206884d205cfa393d89e0f84a","salary-survey-w10a.csv"="fe3d38b8ec469415e5854b93c08d1185")
options(timeout=120)
for(name in names(expected)) {
 target <- file.path(data_dir,name)
 if(!file.exists(target)) {
  url <- paste0("https://raw.githubusercontent.com/lunalab-ai/regre/",tag,"/labs/student/w10a/data/",name)
  status <- download.file(url,target,mode="wb")
  if(status!=0) stop("Download failed: check connection; rerun preparation.")
  cat(name,": fixed-tag download\n")
 } else cat(name,": bundled/cache file\n")
 if(unname(tools::md5sum(target))!=expected[[name]])
  stop("File bytes differ. Preserve your edited file; prepare a fresh folder.")
}
source(file.path(data_dir,"diagnostics-base-w09b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-influence.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-effects.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-learning.R"),encoding="UTF-8")
toy <- read.csv(file.path(data_dir,"hand-five-w10a.csv"))
ny <- read.csv(file.path(data_dir,"nyrivers-w10a.csv"))
hills <- read.csv(file.path(data_dir,"scottish-hills-w10a.csv"))
salary <- read.csv(file.path(data_dir,"salary-survey-w10a.csv"))
ft <- lm(y~x,toy); fn <- lm(Nitrogen~ComIndl,ny)
fh <- lm(Time~Distance+Climb,hills)
# E02/E03: predict first, then refit with all x held fixed.
shift <- learning_point_shift(toy,3,10)
print(shift$trace)
print(diag_influence(ft),digits=6)
qtable <- learning_qq_table(residuals(ft)); print(qtable)
par(mfrow=c(1,2))
plot(toy$x,toy$y,xlab="x",ylab="y",main="Observed and fitted"); abline(ft,col="steelblue",lwd=2)
qqnorm(rstandard(ft),main="Normal Q-Q: sorted residuals");qqline(rstandard(ft))
par(mfrow=c(1,1))
# E07: specify the exact model, units and original row IDs.
ni <- diag_influence(fn);print(ni[c(4,5),c("row","h","internal","Cook","potential","residual_component")])
plot(ni$residual_component,ni$potential,xlab="Hadi residual component R",ylab="Potential P")
text(ni$residual_component,ni$potential,labels=ni$row,pos=3,cex=.7)
# E08/E09: same 35 rows, Time seconds / Distance miles / Climb feet.
av <- diag_added_variable(fh,"Distance"); cp <- diag_component_residual(fh,"Distance")
print(av$data[1,]);print(cp[1,]);print(av$slope)
par(mfrow=c(1,2))
plot(av$data$x_residual,av$data$y_residual,xlab="Distance residual (miles)",ylab="Time residual (seconds)");abline(0,av$slope,col="steelblue")
plot(cp$x,cp$component_residual,xlab="Original Distance (miles)",ylab="Component + residual (seconds)");abline(0,coef(fh)["Distance"],col="steelblue")
par(mfrow=c(1,1))
if(!requireNamespace("MASS",quietly=TRUE)) stop("Use bundled R/MASS or the installation-free online R route.")
rob <- MASS::rlm(Time~Distance+Climb,hills,maxit=100)
print(data.frame(row=c(7,11,18),h=hatvalues(fh)[c(7,11,18)],weight=rob$w[c(7,11,18)]))
print(list(converged=rob$converged,df=rob$df.residual))
# E11/E12: full 46 rows first. E is a category code, not an amount.
sa <- salary_fit(salary,FALSE); si <- salary_fit(salary,TRUE)
print(coef(sa));print(coef(si))
print(data.frame(model=c("46 additive","46 interaction"),n=c(nobs(sa),nobs(si)),k=c(sa$rank,si$rank),df=c(df.residual(sa),df.residual(si)),s=c(sigma(sa),sigma(si))))
print(salary_group_predictions(sa,5));print(salary_group_predictions(si,5))
print(salary_group_gaps(sa,5));print(salary_group_gaps(si,5))
pr <- salary_group_predictions(si,5)
plot(seq_len(6),pr$S_hat,xaxt="n",xlab="Education x management group",ylab="Fitted group mean (USD/year)",pch=19)
axis(1,at=seq_len(6),labels=paste(pr$Education,pr$M,sep="/"),cex.axis=.65)
# Same 46 rows, changed reference only: fitted values remain invariant.
si_ref <- salary_fit(salary,TRUE,reference=1)
print(max(abs(fitted(si)-fitted(si_ref))))
# Explicit sensitivity: preserve all source rows, omit only in this separate fit.
sd <- salary_fit(salary,TRUE,omit_row=33)
print(c(n=nobs(sd),df=df.residual(sd),s=sigma(sd)))
print(salary_group_predictions(sd,0)) # Outside observed experience range: extrapolation.

# TODO L01: 교육용 5행에서 x=(0,1,2,3,4), y=(1,2,2,4,4), 적합식은 yhat=1+0.8x입니다. 2번의 예측과 잔차를 구하고 관측이 선의 어느 쪽인지 설명하세요. 단위는 교육용 y 단위입니다.
# TODO L02: 같은 5행, xbar=2, Sxx=10, SSE=0.8, n=5, k=2입니다. 4번 x=3, e=0.6의 h를 구하세요. 모든 x를 고정하고 이 점의 y만 −5만큼 이동할 때 자기 예측·잔차의 변화량은? 원래 자료에서 내적·외적 표준화잔차도 구하세요. 삭제 후 SSE=0.2857142857, 자유도=2입니다.
# TODO L03: 실제 측정순서 1~5에서 잔차가 (−2,−1,0,1,2)입니다. ppoints(5)의 확률은 (0.119048,0.309524,0.5,0.690476,0.880952), 대응 정규 분위수는 (−1.179761,−0.497201,0,0.497201,1.179761)입니다. 세 번째 Q-Q 점과 순서 플롯 점을 쓰세요. 잔차 순서를 (0,−2,2,−1,1)로 바꾸면 무엇이 달라지나요?
# TODO L04: NY 단순모형 Nitrogen~ComIndl, n=20, k=2에서 7번 e=0.699492144237, h=0.082605785602, SSE=2.5953991583입니다. d2=e^2/SSE, P=h/(1−h), R=k/(1−h)×d2/(1−d2)로 P-R 좌표와 H를 구하세요. Nitrogen은 공식 자료의 원래 척도입니다.
# TODO L05: Hills 35행, Time 초·Distance 마일·Climb 피트. 2번은 (Time,Distance,Climb)=(2901,6,2500). 같은 35행에서 Time~Climb 예측은 4494.933103, Distance~Climb 예측은 9.052381입니다. 전체 Time~Distance+Climb에서 2번 잔차 −455.173131, 거리 계수 373.0726769입니다. AV와 성분잔차 좌표를 각각 구하세요. AV 기울기를 2번 한 점의 세로/가로 비로 구해도 될까요?
# TODO L06: 전체 46명 상호작용 모형: b0=11203.433772, bX=496.987011, bE2=−349.077692, bM=7047.412024, bE2M=1836.487946. X=8 학사 관리직의 평균 급여와 같은 경력 학사 관리직 격차를 구하세요. 이어 앱 편집기의 W10A_L06에서 delta_fitted를 delta_residual로 바꾸고 출력 제목도 바꾸세요. 5번·이동 −5에서 예상 두 변화량을 적고 CSV와 수정 R을 저장한 뒤 재시작하세요.
# TODO L07: 교육용 5행의 모든 y를 100배하여 다시 적합하면 원 잔차, s, h, 내적 잔차, Cook은 각각 어떻게 달라질까요? x는 고정합니다.
# TODO L08: 교육용 5행 2번은 e=0.2,h=0.3,SSE=0.8,자유도3입니다. 삭제 후 SSE=0.7428571429,자유도2일 때 내적·외적 표준화잔차를 계산하고 항상 외적 절댓값이 더 큰지 판단하세요.
# TODO L09: Hills의 Time 열을 잔차–수집순서 플롯의 가로축으로 바로 써도 될까요? Q-Q가 거의 직선이면 원래 평균이 선형이라고 확정해도 될까요? 임의 ID가 기록순서를 보장하나요?
# TODO L10: 교육용 5행 5번은 e=−0.2,h=0.6,SSE=0.8,자유도3,k=2입니다. 외적 잔차 −0.534522484를 이용해 DFFITS, P, R, H를 구하세요. DFFITS가 음수이면 Cook도 음수인가요?
# TODO L11: Huber c=1.345, 표준화 잔차 u=(0.5,2,4)에 대해 w=min(1,c/abs(u))를 계산하세요. 높은 h인 점이 반드시 작은 가중치를 받나요? MASS::rlm의 df.residual=NA는 수렴 실패인가요?
# TODO L12: 절편과 학력 3개 더미를 모두 넣으면 왜 중복인가요? 기준을 대학원에서 고졸로 바꾼 같은 모형의 적합값은? 전체46명 상호작용 모형에서 X=5 학사 관리직 평균의 95% 신뢰구간 [22083.888,22362.494]를 해석하세요. 개인 급여의 95% 범위라고 해도 되나요?
