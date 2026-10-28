# W09B 학생 R 실습. 같은 QMD의 실행 셀이며 TODO는 주석입니다.
# 고정 자산/단위/API는 동봉 README와 diagnostics-influence-api.md를 확인하세요.

# 0. 독립 실행 준비

tag <- "2026-fall-w09b"
local_dirs <- c("data","labs/student/w09b/data","../../labs/student/w09b/data","../../../labs/student/w09b/data")
found <- local_dirs[file.exists(file.path(local_dirs,"diagnostics-influence.R"))]
data_dir <- if(length(found)) found[1] else file.path(path.expand("~"),".cache","regre",tag)
dir.create(data_dir,recursive=TRUE,showWarnings=FALSE)
expected <- c("diagnostics-base-w09b.R"="1d6d198179eb52922e0b7da3a3836838","diagnostics-influence.R"="106f87499e0a0565f4c19d75b7e26c9a","diagnostics-effects.R"="df333742f83c7f635427673c62acf214","hand-six-w09b.csv"="313e3e377db6f34c55963371366bcfe1","nyrivers-w09b.csv"="6f67635643fbb5aac0b37b7a8fed0d26","scottish-hills-w09b.csv"="ea6e5b9206884d205cfa393d89e0f84a")
paths <- c("diagnostics-base-w09b.R"="src/diagnostics.R","diagnostics-influence.R"="src/diagnostics-influence.R","diagnostics-effects.R"="src/diagnostics-effects.R","hand-six-w09b.csv"="data/sample/w09b/hand-six-w09b.csv","nyrivers-w09b.csv"="data/sample/w09b/nyrivers-w09b.csv","scottish-hills-w09b.csv"="data/sample/w09b/scottish-hills-w09b.csv")
options(timeout=120)
for(name in names(paths)) {
  target <- file.path(data_dir,name)
  if(!file.exists(target)) {
    address <- paste0("https://raw.githubusercontent.com/lunalab-ai/regre/",tag,"/",paths[[name]])
    status <- download.file(address,target,mode="wb")
    if(status!=0) stop("다운로드 실패: 인터넷 연결을 확인하고 준비 셀을 다시 실행하세요.")
    cat(name,": fixed-tag first download\n")
  } else cat(name,": bundled file or cache verified\n")
  if(unname(tools::md5sum(target))!=expected[[name]]) stop("파일 동일성 불일치: 수정 파일을 보존하고 별도 폴더에서 고정 버전을 다시 준비하세요.")
}
source(file.path(data_dir,"diagnostics-base-w09b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-influence.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-effects.R"),encoding="UTF-8")
toy <- read.csv(file.path(data_dir,"hand-six-w09b.csv"))
ny <- read.csv(file.path(data_dir,"nyrivers-w09b.csv"))
hills <- read.csv(file.path(data_dir,"scottish-hills-w09b.csv"))
fit_review <- lm(rating~complaints+learning,data=datasets::attitude)
fit_toy <- lm(y~x,data=toy)
fit_ny_simple <- lm(Nitrogen~ComIndl,data=ny)
fit_ny_full <- lm(Nitrogen~Agr+Forest+Rsdntial+ComIndl,data=ny)
fit_hills <- lm(Time~Distance+Climb,data=hills)
toy_influence <- diag_influence(fit_toy)
ny_influence <- diag_influence(fit_ny_simple)
av_distance <- diag_added_variable(fit_hills,"Distance")
cpr_distance <- diag_component_residual(fit_hills,"Distance")
cat(R.version.string,"\nRows: six=",nrow(toy)," NY=",nrow(ny)," Hills=",nrow(hills),"\n")

# 1. 6행 표의 계산 사슬

toy
c(coefficients=coef(fit_toy),SSE=deviance(fit_toy),s=sigma(fit_toy))
toy_influence[4,c("raw","h","internal","external","Cook","DFFITS","potential","residual_component","Hadi")]
i <- 4L
deleted4 <- diag_deleted_fit(fit_toy,i)
c(Cook_formula=toy_influence$Cook[i],Cook_refit=deleted4$Cook)
plot(toy$x,toy$y,pch=19,col="#2166AC",xlab="x (teaching units)",ylab="y (teaching units)")
abline(fit_toy,col="#D6604D",lwd=2)

# L01 · 한 행의 잔차와 표준화 — 필수

# L01: 식의 각 항과 단위를 먼저 적고 아래 주석을 완성하세요.
# your_calculation <- ...

# L02 · Cook·DFFITS·Hadi 계산 사슬 — 필수

# L02: 식의 각 항과 단위를 먼저 적고 아래 주석을 완성하세요.
# your_calculation <- ...

# 2. 같은 두 강을 여러 진단으로 연결

ny_influence[4:5,c("row","internal","external","h","Cook","DFFITS","potential","residual_component","Hadi")]
plot(ny_influence$residual_component,ny_influence$potential,pch=19,
 xlab="Residual component R",ylab="Potential P",col="#2166AC")
text(ny_influence$residual_component[4:5],ny_influence$potential[4:5],labels=4:5,pos=4)
ny_influence[7,c("raw","h")]
c(SSE=deviance(fit_ny_simple),k=fit_ny_simple$rank,df=df.residual(fit_ny_simple))

# L03 · 다른 강의 P-R 좌표와 추가 확인 — 필수

# L03: d_squared <- ...
# P <- ...; R <- ...; H <- ...

# 3. 양쪽 잔차화와 성분잔차

coef(fit_hills)
rx <- residuals(lm(Distance~Climb,data=hills))
ry <- residuals(lm(Time~Climb,data=hills))
c(AV_slope=sum(rx*ry)/sum(rx^2),full_coefficient=coef(fit_hills)["Distance"])
head(av_distance$data)
cpr_distance[1,]
plot(av_distance$data$x_residual,av_distance$data$y_residual,pch=19,
 xlab="Distance residual (miles)",ylab="Time residual (seconds)",col="#2166AC")
abline(a=0,b=av_distance$slope,col="#D6604D",lwd=2)

# L04 · Climb의 첨가변수 기울기 — 필수

# L04: 같은 관측과 단위를 확인한 뒤 계산하세요.
# your_calculation <- ...

# L05 · 둘째 경주의 성분잔차 — 필수

# L05: 같은 관측과 단위를 확인한 뒤 계산하세요.
# your_calculation <- ...

# 4. 변수 추가와 로버스트 비교

if(!requireNamespace("MASS",quietly=TRUE)) stop("MASS 패키지가 필요합니다. 브라우저는 로딩 완료를 기다리고, 데스크톱은 준비 안내를 확인하세요.")
fit_hills_robust <- MASS::rlm(Time~Distance+Climb,data=hills)
cbind(OLS=coef(fit_hills),Huber_M=coef(fit_hills_robust))
data.frame(row=c(7,11,18),h=hatvalues(fit_hills)[c(7,11,18)],weight=fit_hills_robust$w[c(7,11,18)])
list(converged=fit_hills_robust$converged,residual_df=fit_hills_robust$df.residual)
c(Distance_only=coef(lm(Time~Distance,data=hills))["Distance"],Distance_adjusted=coef(fit_hills)["Distance"])

# 5. 누적 앱에서 출력 연결

# L06: 편집기에서 W09B_L06 표식을 찾아 출력 연결 한 곳을 수정합니다.
# 수정 전 예상, 수정한 필드와 라벨, 두 관측의 실제 출력을 기록하세요.

# L07 · W06A의 다른 부서로 전이 — 확장

# L07: 식/코드와 해석을 직접 작성하세요.
# your_check <- ...

# L08 · 정규성 진단 코드의 대상 오류 — 확장·디버깅

# L08: 식/코드와 해석을 직접 작성하세요.
# your_check <- ...

# L09 · 삭제 민감도와 분석상 제외의 차이 — 확장

# L09: 식/코드와 해석을 직접 작성하세요.
# your_check <- ...

# L10 · 새 변수 추가의 네 상황 — 확장

# L10: 식/코드와 해석을 직접 작성하세요.
# your_check <- ...

# L11 · Huber 가중치의 의미 — 확장

# L11: 식/코드와 해석을 직접 작성하세요.
# your_check <- ...

# L12 · 정의되지 않는 진단과 기록 — 확장

# L12: 식/코드와 해석을 직접 작성하세요.
# your_check <- ...

# 기본 실행 자가 검사

local({
stopifnot(nrow(toy)==6,nrow(ny)==20,df.residual(fit_toy)==4,
 max(abs(toy_influence$Cook-cooks.distance(fit_toy)))<1e-9,
 max(abs(ny_influence$DFFITS-dffits(fit_ny_simple)))<1e-9,
 abs(diag_deleted_fit(fit_ny_simple,4)$Cook-ny_influence$Cook[4])<1e-9)
cat("W09B_INFLUENCE_RUNTIME_CHECK_PASSED\n")
})

# 변수 효과 실행 자가 검사

local({
stopifnot(nrow(hills)==35,df.residual(fit_hills)==32,hills$Time[23]==2859,
 abs(av_distance$slope-coef(fit_hills)["Distance"])<1e-8,
 max(abs(cpr_distance$component_residual-residuals(fit_hills)-coef(fit_hills)["Distance"]*hills$Distance))<1e-8,
 fit_hills_robust$converged,length(fit_hills_robust$w)==35,is.na(fit_hills_robust$df.residual))
cat("W09B_EFFECTS_RUNTIME_CHECK_PASSED\n")
})
