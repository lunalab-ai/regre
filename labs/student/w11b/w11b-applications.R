# W11B · Student inspectable examples
# Bundled inputs first. A fixed-tag download is used only when no local copy exists.
tag <- "2026-fall-w11b"
local_dirs <- c("data","labs/student/w11b/data","../../labs/student/w11b/data","../../../labs/student/w11b/data")
found <- local_dirs[file.exists(file.path(local_dirs,"indicator-applications-w11b.R"))]
cache_root <- Sys.getenv("REGRE_CACHE_DIR",unset=file.path(path.expand("~"),".cache","regre"))
data_dir <- if(length(found)) found[1] else file.path(cache_root,tag)
dir.create(data_dir,recursive=TRUE,showWarnings=FALSE)
expected <- c("categorical-trace-w11b.R"="cd201e03f0de484b2ee9bb71b7d56e24","indicator-applications-w11b.R"="dcbf19df1dfa8c0618b4577fe649aec5","ski-sales-w11b.csv"="0ccf5e3ffa6992bdb40ba2977addd87c","education-w11b.csv"="8ed5c621f5a02c46ca4654c81d3644d0","fertilizer-w11b.csv"="d9adb09eac8823b7a3d21b0a84b757df")
options(timeout=120)
for(name in names(expected)) {
 target <- file.path(data_dir,name)
 if(!file.exists(target)) {
  status <- download.file(paste0("https://raw.githubusercontent.com/lunalab-ai/regre/",tag,"/labs/student/w11b/data/",name),target,mode="wb")
  if(status!=0) stop("Download failed: check the connection and rerun this preparation cell.")
  cat(name,": fixed-tag download\n")
 } else cat(name,": bundled/cache file\n")
 if(unname(tools::md5sum(target))!=expected[[name]])
  stop("Input bytes differ. Preserve your edited copy and use a fresh data folder/cache.")
}
source(file.path(data_dir,"categorical-trace-w11b.R"),encoding="UTF-8")
source(file.path(data_dir,"indicator-applications-w11b.R"),encoding="UTF-8")
ski_raw <- read.csv(file.path(data_dir,"ski-sales-w11b.csv"))
edu_raw <- read.csv(file.path(data_dir,"education-w11b.csv"))
corn <- read.csv(file.path(data_dir,"fertilizer-w11b.csv"))
toy <- data.frame(source_row=1:9,y=c(4,5,6,6,7,8,8,9,10),Group=factor(rep(c("A","B","C"),each=3),levels=c("C","A","B")))
contrasts(toy$Group) <- contr.treatment(levels(toy$Group),base=1)
ski <- ia_quarter_prepare(ski_raw)
edu <- ia_year_prepare(edu_raw)
stopifnot(nrow(ski)==40,nrow(edu)==150,nrow(corn)==40,all(table(ski$Quarter)==10),all(table(edu$YearGroup)==50))
cat("W11B_DATA_READY: own9 / Ski40 / Education150 / Corn40.\n")
print(R.version.string)

# E01 집단의 평균을 회귀식으로 복원
m0 <- lm(y~1,toy)
m1 <- lm(y~Group,toy)
print(toy);print(model.matrix(m1));print(coef(m1))
print(aggregate(y~Group,toy,mean))

# E02 집단내·집단간 변동을 직접 계산
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
parts <- ia_mean_parts(toy$y,toy$Group)
print(parts$rows);print(parts$summary)
stopifnot(abs(parts$summary$SST-parts$summary$SSB-parts$summary$SSE)<1e-10)
plot(as.numeric(toy$Group),toy$y,pch=19,xaxt="n",xlab="Group (C baseline)",ylab="y (own example)")
axis(1,at=1:3,labels=levels(toy$Group))
points(1:3,tapply(toy$y,toy$Group,mean),pch=18,col="blue",cex=2)

# E03 QR→예측→잔차→제곱→합
cat_fit_trace <- function(fit) {
  frame <- cat_check_fit(fit)
  design <- model.matrix(fit)
  observed <- model.response(frame)
  beta <- qr.coef(qr(design),observed)
  fitted <- drop(design %*% beta)
  residual <- observed-fitted
  squared <- residual^2
  rows <- data.frame(source_row=rownames(design),observed=unname(observed),
    fitted=unname(fitted),residual=unname(residual),squared=unname(squared),
    cumulative=cumsum(unname(squared)),row.names=NULL)
  list(design=design,coefficients=beta,rows=rows,
    SSE=sum(squared),n=nrow(design),k=ncol(design),df=df.residual(fit))
}
toy_trace <- cat_fit_trace(m1)
print(toy_trace$rows);print(toy_trace$coefficients)

# E04 부분 F의 분자와 분모를 한 줄씩 확인
cat_nested_trace <- function(reduced, full, tolerance=1e-9) {
  checked <- cat_check_pair(reduced,full,tolerance)
  SSE_reduced <- sum(residuals(reduced)^2)
  SSE_full <- sum(residuals(full)^2)
  if (SSE_full<=0 ||
      SSE_reduced<SSE_full-tolerance*max(1,SSE_reduced))
    stop("F needs positive full-model residual variance and a valid nested SSE.")
  q <- checked$q
  df_full <- checked$df_full
  # A tiny negative difference can only be numerical roundoff for nested OLS.
  increase <- max(0,SSE_reduced-SSE_full)
  F <- (increase/q)/(SSE_full/df_full)
  data.frame(n=checked$n,k_reduced=reduced$rank,k_full=full$rank,q=q,
    df_full=df_full,SSE_reduced=SSE_reduced,SSE_full=SSE_full,
    F=F,p=pf(F,q,df_full,lower.tail=FALSE))
}
toy_test <- cat_nested_trace(m0,m1)
print(toy_test);print(anova(m0,m1))

# E05 행 순서 대신 Date에서 분기를 읽기
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
ski <- ia_quarter_prepare(ski_raw,reference=4)
season0 <- lm(Sales~PDI,ski)
season <- lm(Sales~PDI+Quarter,ski)
print(ski[1:8,c("source_row","Date","PDI","QuarterNumber","Quarter")])
print(model.matrix(season)[1:8,]);print(coef(season))

# E06 계절 평균과 시간 잔차를 구별
season_test <- cat_nested_trace(season0,season)
print(season_test);print(anova(season0,season))
plot(ski$source_row,resid(season0),type="b",col="gray50",xlab="Original quarter order",ylab="Sales residual (original scale)")
lines(ski$source_row,resid(season),col="blue",type="b");abline(h=0,lty=2)
acf(resid(season),main="Residual ACF after seasonal mean terms")
ski_ref1 <- ia_quarter_prepare(ski_raw,1)
season_ref1 <- lm(Sales~PDI+Quarter,ski_ref1)
print(max(abs(fitted(season)-fitted(season_ref1))))

# E07 150행을 두 연도 지시변수와 곱항으로 펼치기
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
edu <- ia_year_prepare(edu_raw,1975)
print(edu[1:4,c("source_row","STATE","Year","Y","X1","X2","X3","YearGroup")])

# E08 직접 수정할 모형 함수와 실제 호출
ia_full_formula <- function() {
  Y ~ (X1 + X2 + X3) * YearGroup
}
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
year_models <- ia_year_models(edu,ia_full_formula)
print(vapply(year_models,function(f) f$rank,integer(1)))
print(model.matrix(year_models$full)[1:4,]);print(coef(year_models$full))

# E09 4개에서12개 계수: 새 제약8개와 잔차 자유도138
cat_fit_trace <- function(fit) {
  frame <- cat_check_fit(fit)
  design <- model.matrix(fit)
  observed <- model.response(frame)
  beta <- qr.coef(qr(design),observed)
  fitted <- drop(design %*% beta)
  residual <- observed-fitted
  squared <- residual^2
  rows <- data.frame(source_row=rownames(design),observed=unname(observed),
    fitted=unname(fitted),residual=unname(residual),squared=unname(squared),
    cumulative=cumsum(unname(squared)),row.names=NULL)
  list(design=design,coefficients=beta,rows=rows,
    SSE=sum(squared),n=nrow(design),k=ncol(design),df=df.residual(fit))
}
cat_nested_trace <- function(reduced, full, tolerance=1e-9) {
  checked <- cat_check_pair(reduced,full,tolerance)
  SSE_reduced <- sum(residuals(reduced)^2)
  SSE_full <- sum(residuals(full)^2)
  if (SSE_full<=0 ||
      SSE_reduced<SSE_full-tolerance*max(1,SSE_reduced))
    stop("F needs positive full-model residual variance and a valid nested SSE.")
  q <- checked$q
  df_full <- checked$df_full
  # A tiny negative difference can only be numerical roundoff for nested OLS.
  increase <- max(0,SSE_reduced-SSE_full)
  F <- (increase/q)/(SSE_full/df_full)
  data.frame(n=checked$n,k_reduced=reduced$rank,k_full=full$rank,q=q,
    df_full=df_full,SSE_reduced=SSE_reduced,SSE_full=SSE_full,
    F=F,p=pf(F,q,df_full,lower.tail=FALSE))
}
year_trace <- cat_fit_trace(year_models$full)
year_test <- cat_nested_trace(year_models$common,year_models$full)
print(year_trace$rows[1:6,]);print(year_test)
print(anova(year_models$common,year_models$full))
one_state <- edu[1,,drop=FALSE]
one_state$YearGroup <- factor(as.character(one_state$YearGroup),levels=levels(edu$YearGroup))
print(cat_row_trace(year_models$full,one_state))

# E10 기준 변경의 불변성과 관측 범위
edu_ref1960 <- ia_year_prepare(edu_raw,1960)
other_reference <- ia_year_models(edu_ref1960,ia_full_formula)
print(max(abs(fitted(year_models$full)-fitted(other_reference$full))))
print(aggregate(X1~YearGroup,edu,range))
plot(fitted(year_models$full),edu$Y,col=as.integer(edu$YearGroup),pch=19,xlab="Fitted Y (original scale)",ylab="Observed Y (original scale)")
abline(0,1,lty=2)

# E11 수정 코드에서 앱·CSV·R 저장본으로
student_formula <- function() {
 Y ~ (X1 + X2 + X3) * YearGroup
}
my_models <- ia_year_models(edu,student_formula)
print(cat_nested_trace(my_models$common,my_models$full))

# L01 자체9개 예에서 기준을 B로 바꾸고 C집단의 설계행렬 한 행과 평균을 먼저 적으세요. 기준을 바꿀 때 삭제되는 관측이 있는지도 설명하세요.
my_L01_prediction <- NA_real_
my_L01_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L02 새 자체 자료 A=(2,4,6), B=(5,7,9), C=(6,8,10)의 집단평균·전체평균·SSE·집단간SS·F를 손으로 계산하고 검산하세요.
my_L02_prediction <- NA_real_
my_L02_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L03 스키 원자료의 행을 뒤집어 준비하세요. Date로 만든 분기와 rep(1:4,10)으로 만든 분기가 언제 어긋나는지 보이세요. Q1기준과 Q4기준의 적합값도 비교하세요.
my_L03_prediction <- NA_real_
my_L03_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L04 `Sales ~ PDI + QuarterNumber`와 `Sales ~ PDI + Quarter`의 설계열·계수 수를 비교하세요. 전자의 숨은 제약을 말하고 의도한 분기 모형으로 고치세요.
my_L04_prediction <- NA_real_
my_L04_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L05 공통모형4계수와 전체모형12계수를 비교할 때 q와 분모 자유도를 적으세요. SSE전체/(150−4)를 분모로 쓴 코드를 왜 고쳐야 하나요?
my_L05_prediction <- NA_real_
my_L05_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L06 student_formula의 *를 +로 바꾼 사본을 실행하세요. 앱 편집기에도 같은 함수를 반영하고 Run 후 표·그림·CSV·독립 실행 R을 저장하세요. 새 R세션에서 저장본을 재실행하세요.
my_L06_prediction <- NA_real_
my_L06_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L07 Q1/Q4와 Q2/Q3를 두 묶음으로 둔 모형을 네 분기 모형과 비교하세요. 비유의 결과의 의미를 한 문장으로 쓰세요.
my_L07_prediction <- NA_real_
my_L07_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L08 40행인 두 적합 중 하나의 반응값 또는 관측 순서가 다릅니다. 같은 n만 확인해 부분 F를 계산해도 되는지 설명하고 검사 함수가 거부하는지 확인하세요.
my_L08_prediction <- NA_real_
my_L08_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

# L09 제품5종과 연속 지름 하나로 작업시간을 설명합니다. 절편·기울기를 모두 제품별로 허용하면 계수는 몇 개인가요? 59행에서 공통직선과 비교할 q·잔차df를 적으세요.
my_L09_prediction <- NA_real_
my_L09_reason <- ""
# Your answer is separate: unfinished exercises do not block later examples.

stopifnot(abs(parts$summary$SSE-6)<1e-10,abs(toy_test$F-12)<1e-9,toy_test$q==2,toy_test$df_full==6,
 nrow(ski)==40,season$rank==5,season_test$q==3,season_test$df_full==35,
 abs(season_test$F-anova(season0,season)$F[2])<1e-8,
 max(abs(fitted(season)-fitted(season_ref1)))<1e-9)
cat("W11B_MEAN_SEASON_RUNTIME_PASS: source calculations, not exercise completion\n")
stopifnot(nrow(edu)==150,year_models$common$rank==4,year_models$intercept$rank==6,year_models$full$rank==12,
 year_test$q==8,year_test$df_full==138,abs(year_test$F-anova(year_models$common,year_models$full)$F[2])<1e-8,
 max(abs(year_trace$rows$fitted-fitted(year_models$full)))<1e-7,
 max(abs(fitted(year_models$full)-fitted(other_reference$full)))<1e-7)
cat("W11B_STABILITY_RUNTIME_PASS: source calculations, not exercise completion\n")
