# W11A · Inspectable student examples
# Prefer bundled files; otherwise download the reviewed, fixed release once.
tag <- "2026-fall-w11a"
local_dirs <- c("data","labs/student/w11a/data","../../labs/student/w11a/data","../../../labs/student/w11a/data")
found <- local_dirs[file.exists(file.path(local_dirs,"categorical-trace-w11a.R"))]
cache_root <- Sys.getenv("REGRE_CACHE_DIR",unset=file.path(path.expand("~"),".cache","regre"))
data_dir <- if(length(found)) found[1] else file.path(cache_root,tag)
dir.create(data_dir,recursive=TRUE,showWarnings=FALSE)
expected <- c("diagnostics-learning-w11a.R"="7ba534cc7178c9c6bbfde87f650926ca","categorical-trace-w11a.R"="cd201e03f0de484b2ee9bb71b7d56e24","salary-survey-w11a.csv"="fe3d38b8ec469415e5854b93c08d1185","preemployment-w11a.csv"="b07cddce30abfd0c25e84d9640733b53")
options(timeout=120)
for(name in names(expected)) {
 target <- file.path(data_dir,name)
 if(!file.exists(target)) {
  status <- download.file(paste0("https://raw.githubusercontent.com/lunalab-ai/regre/",tag,"/labs/student/w11a/data/",name),target,mode="wb")
  if(status!=0) stop("Download failed. Check your connection and rerun preparation.")
  cat(name,": fixed-tag download\n")
 } else cat(name,": bundled/cache file\n")
 if(unname(tools::md5sum(target))!=expected[[name]])
  stop("File bytes differ. Preserve your edited file; use a fresh folder or cache.")
}
source(file.path(data_dir,"diagnostics-learning-w11a.R"),encoding="UTF-8")
source(file.path(data_dir,"categorical-trace-w11a.R"),encoding="UTF-8")
salary <- read.csv(file.path(data_dir,"salary-survey-w11a.csv"))
pre <- read.csv(file.path(data_dir,"preemployment-w11a.csv"))
stopifnot(nrow(salary)==46,nrow(pre)==20,salary$S[1]==13876,pre$TEST[1]==.28)
sa <- salary_fit(salary,FALSE); si <- salary_fit(salary,TRUE)
mods <- cat_two_group_models(pre)
cat("W11A_DATA_READY: Salary46 / Preemployment20; original source rows retained\n")


# E01 · 범주의0/1 행을 실제로 확인
salary_prepare <- function(data, reference=3L) {
  columns <- c("S","X","E","M")
  if (!is.data.frame(data) || !all(columns %in% names(data)) || nrow(data)<8L ||
      !all(vapply(data[columns],is.numeric,logical(1))) ||
      any(!is.finite(as.matrix(data[columns]))) ||
      any(!data$E %in% 1:3) || any(!data$M %in% 0:1))
    stop("Use complete finite S/X/E/M data; E=1,2,3 and M=0,1.")
  if (length(reference)!=1L || !is.numeric(reference) || !is.finite(reference) ||
      !reference %in% 1:3) stop("reference must be education code 1, 2 or 3.")
  labels <- c("HighSchool","Bachelor","Graduate")
  d <- data[columns]
  d$row_id <- seq_len(nrow(d))
  d$Education <- factor(labels[d$E],levels=c(labels[reference],labels[-reference]))
  contrasts(d$Education) <- contr.treatment(levels(d$Education),base=1)
  d
}
d <- salary_prepare(salary)
print(d[1:6,c("row_id","E","M","Education")])
print(model.matrix(sa)[1:6,])

# E02 · 한 사람의 항별 기여를 추적
cat_row_trace <- function(fit, newdata) {
  cat_check_fit(fit)
  if (!is.data.frame(newdata) || nrow(newdata)<1L)
    stop("newdata must contain at least one complete observation.")
  term <- delete.response(terms(fit))
  frame <- model.frame(term,newdata,na.action=na.fail,xlev=fit$xlevels)
  design <- model.matrix(term,frame,contrasts.arg=fit$contrasts)
  beta <- coef(fit)
  if (!identical(colnames(design),names(beta)) || any(!is.finite(design)))
    stop("New rows must use the fitted columns, factor levels and finite values.")
  contribution <- sweep(design,2,beta,"*")
  data.frame(row=rep(seq_len(nrow(design)),each=ncol(design)),
    term=rep(colnames(design),times=nrow(design)),
    value=as.vector(t(design)),coefficient=rep(unname(beta),times=nrow(design)),
    contribution=as.vector(t(contribution)),row.names=NULL)
}
one <- data.frame(X=5,Education=factor("Bachelor",levels=sa$xlevels$Education),M=1)
additive_row <- cat_row_trace(sa,one)
print(additive_row,digits=6)
print(c(sum_of_terms=sum(additive_row$contribution),predict=unname(predict(sa,one))))
barplot(additive_row$contribution,names.arg=additive_row$term,las=2,cex.names=.6,ylab="Contribution (USD/year)")

# E03 · 어떤 항을 추가해 다시 적합하는가
salary_fit <- function(data, interaction=FALSE, omit_row=integer(), reference=3L) {
  if (length(interaction)!=1L || !is.logical(interaction) || is.na(interaction))
    stop("interaction must be TRUE or FALSE.")
  d <- salary_prepare(data,reference)
  if (!is.numeric(omit_row) || any(!is.finite(omit_row)) ||
      any(omit_row!=as.integer(omit_row)) || any(!omit_row %in% d$row_id))
    stop("omit_row must contain valid original row IDs, or integer().")
  selected <- d[!d$row_id %in% omit_row,,drop=FALSE]
  groups <- table(selected$Education,factor(selected$M,levels=0:1))
  if (any(groups==0L))
    stop("Keep observations in all six education/management groups for this teaching comparison.")
  formula <- if (interaction) S~X+Education*M else S~X+Education+M
  fit <- lm(formula,data=selected)
  if (fit$rank!=ncol(model.matrix(fit)) || df.residual(fit)<1L)
    stop("Selected rows do not support a full-rank model with residual degrees of freedom.")
  attr(fit,"salary_rows") <- selected$row_id
  attr(fit,"salary_interaction") <- interaction
  fit
}
full_row <- cat_row_trace(si,one)
print(full_row,digits=6)
print(salary_group_gaps(si,5),digits=6)
print(c(additive=sigma(sa),interaction=sigma(si)))

# 실제 최소제곱 계산을 안쪽에서 보기
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
salary_trace <- cat_fit_trace(si)
print(salary_trace$design[1:6,])
print(salary_trace$coefficients)
print(salary_trace$rows[1:6,],digits=6)
print(c(SSE=salary_trace$SSE,df=salary_trace$df,sigma=sqrt(salary_trace$SSE/salary_trace$df)))

# E04 · 기준 변경과 원자료 보존 민감도
reference1 <- salary_fit(salary,TRUE,reference=1)
print(coef(si));print(coef(reference1))
print(max(abs(fitted(si)-fitted(reference1))))
sensitivity <- salary_fit(salary,TRUE,omit_row=33)
print(data.frame(model=c("all46","separate45"),n=c(nobs(si),nobs(sensitivity)),sigma=c(sigma(si),sigma(sensitivity))))
print(aggregate(X~E+M,salary,range))

# E05 · 네 모형을 만드는 실제 정의
cat_two_group_models <- function(data) {
  columns <- c("TEST","RACE","JPERF")
  if (!is.data.frame(data) || !all(columns %in% names(data)) || nrow(data)<6L ||
      !all(vapply(data[columns],is.numeric,logical(1))) ||
      any(!is.finite(as.matrix(data[columns]))) ||
      any(!data$RACE %in% 0:1) || length(unique(data$RACE))!=2L)
    stop("Use complete finite TEST/RACE/JPERF rows with both original 0/1 groups.")
  models <- list(M0=lm(JPERF~TEST,data,na.action=na.fail),
    MI=lm(JPERF~TEST+RACE,data,na.action=na.fail),
    MS=lm(JPERF~TEST+TEST:RACE,data,na.action=na.fail),
    MF=lm(JPERF~TEST*RACE,data,na.action=na.fail))
  invisible(lapply(models,cat_check_fit))
  models
}
mods <- cat_two_group_models(pre)
print(model.matrix(mods$MF)[1:6,])
print(coef(mods$MF))

# Z 대입과 두 직선·집단 차이
cat_group_lines <- function(fit) {
  cat_check_fit(fit)
  beta <- c("(Intercept)"=0,"TEST"=0,"RACE"=0,"TEST:RACE"=0)
  if (!all(names(coef(fit)) %in% names(beta)))
    stop("Use a TEST/RACE model from this two-group comparison.")
  beta[names(coef(fit))] <- coef(fit)
  Z <- 0:1
  data.frame(Z=Z,intercept=unname(beta["(Intercept)"]+beta["RACE"]*Z),
    slope=unname(beta["TEST"]+beta["TEST:RACE"]*Z))
}
cat_gap <- function(gamma, delta, x) {
  if (length(gamma)!=1L || length(delta)!=1L || !is.numeric(gamma) ||
      !is.numeric(delta) || !is.numeric(x) || !length(x) ||
      any(!is.finite(c(gamma,delta,x)))) stop("Use finite scalar gaps and finite x.")
  gamma+delta*x
}
lines_full <- cat_group_lines(mods$MF)
print(lines_full,digits=6)
new_two <- data.frame(TEST=1.5,RACE=0:1)
print(cbind(new_two,prediction=predict(mods$MF,new_two)))
print(cat_gap(diff(lines_full$intercept),diff(lines_full$slope),c(.5,1.5,2.3)))
plot(pre$TEST,pre$JPERF,col=ifelse(pre$RACE==0,"steelblue","darkorange"),pch=19,xlab="TEST",ylab="JPERF")
for(i in 1:2) abline(lines_full$intercept[i],lines_full$slope[i],col=c("steelblue","darkorange")[i],lwd=2)

# E06-1 · 전체20행의 잔차 제곱합
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
trace0 <- cat_fit_trace(mods$M0);traceF <- cat_fit_trace(mods$MF)
print(trace0$rows[1:4,],digits=6);print(traceF$rows[1:4,],digits=6)
print(c(SSE0=trace0$SSE,SSEF=traceF$SSE,dfF=traceF$df))

# E06-2 · 부분 F의 실제 구현
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
comparison <- cat_nested_trace(mods$M0,mods$MF)
print(comparison,digits=9)
print(anova(mods$M0,mods$MF))

# E07 · 세 제약과 서로 다른 비교
comparison_pairs <- list(c("M0","MF"),c("M0","MI"),c("M0","MS"),c("MI","MF"),c("MS","MF"))
comparison_table <- do.call(rbind,lapply(comparison_pairs,function(pair) cbind(reduced=pair[1],full=pair[2],cat_nested_trace(mods[[pair[1]]],mods[[pair[2]]]))))
print(comparison_table,digits=7)

# E08 · 평균 회귀선을 거꾸로 읽기
group1 <- lm(JPERF~TEST,pre[pre$RACE==1,])
beta1 <- coef(group1)
x_at_mean4 <- unname((4-beta1[1])/beta1[2])
print(c(TEST_point_estimate=x_at_mean4,n=nobs(group1),df=df.residual(group1)))

# L06 연결 · 직접 수정하는 모형 함수
student_formula <- function() JPERF ~ TEST * RACE
edited_model <- lm(student_formula(),pre)
print(model.matrix(edited_model)[1:4,])
print(cat_group_lines(edited_model))
print(cat_nested_trace(mods$M0,edited_model))

# L01 고졸·비관리직·경력 4년인 사람의 절편/E1/E2/M/E1M/E2M을 순서대로 쓰세요. 기준은 대학원입니다. 대학원 사람이 자료에서 삭제됐는지도 설명하세요.
my_L01_prediction <- NA_real_
my_L01_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L02 E02의 가법 계수로 고졸·관리직·경력 4년의 평균 연봉을 손으로 구하세요. 경력만 5년으로 바꾸면 얼마나 변하나요? 기준만 고졸로 바꾸면 같은 사람의 예측이 변할까요?
my_L02_prediction <- NA_real_
my_L02_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L03 전체 46명 상호작용 모형에서 고졸의 관리직 격차를 구하고 학사와 비교하세요. 경력을 4년에서 6년으로 바꾸면 각 집단의 연봉 증가량과 관리직 격차는 어떻게 되나요?
my_L03_prediction <- NA_real_
my_L03_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L04 교육용 평균모형 $Y=2+X-Z+2XZ$에서 Z=0/1의 두 선을 쓰세요. X=2에서 각각의 평균과 집단1−0의 차이를 구하세요. X=3에서는 차이가 어떻게 되나요?
my_L04_prediction <- NA_real_
my_L04_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L05 같은 20명에서 M0의 SSE는 45.568297, MF는 31.655473입니다. 두 모형의 계수 수, q, 분모 자유도, F를 직접 계산한 뒤 R과 비교하세요. M0→MI의 분모도 16인지 설명하세요.
my_L05_prediction <- NA_real_
my_L05_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L06 앱 편집기에서 student_formula()의 TEST * RACE를 TEST + RACE로 바꾼 사본을 실행하세요. 바꾸기 전에 사라질 열과 두 기울기의 관계를 예상하세요. 표·그림·SSE/F를 비교하고 수정 R/CSV를 저장한 뒤 재시작하세요.
my_L06_prediction <- NA_real_
my_L06_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L07 절편과 E1/E2/E3을 모두 둔 식에서 절편에 100을 더하고 모든 학력 계수에서 100을 빼면 예측은 어떻게 되나요? 왜 계수가 하나로 정해지지 않나요?
my_L07_prediction <- NA_real_
my_L07_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L08 M0는 20명, MF는 결측값 때문에 19명으로 적합했습니다. 두 SSE를 바로 부분 F에 넣어도 될까요? 급료조사 전체에 경력 20년이 있으면 모든 학력·관리직의 20년 예측이 관측 범위 안인지도 설명하세요.
my_L08_prediction <- NA_real_
my_L08_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L09 교육용 두 선 $Y_0=2+X$와 $Y_1=2+3X$는 X=0에서 같습니다. $X_c=X-1$로 바꾸어 두 식을 쓰세요. 새 절편이 같나요? Xc의 집단 항을 생략하는 것이 원래 제약과 같나요?
my_L09_prediction <- NA_real_
my_L09_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

# L10 전체 비교 p=.054236일 때 미리 정한 5% 기준의 결론을 쓰세요. 한 집단의 기울기만 유의하다는 사실로 두 기울기 차이를 판정할 수 있는지도 설명하세요.
my_L10_prediction <- NA_real_
my_L10_reason <- ""
# Record a prediction first; an unfinished answer does not block the examples.

stopifnot(nrow(salary)==46,nrow(pre)==20,si$rank==7,df.residual(si)==39,
 max(abs(salary_trace$rows$fitted-fitted(si)))<1e-7,
 abs(sum(additive_row$contribution)-predict(sa,one))<1e-7,
 max(abs(fitted(si)-fitted(reference1)))<1e-7)
cat("W11A_CATEGORICAL_RUNTIME_PASS: source calculations, not exercise completion\n")
stopifnot(nrow(pre)==20,mods$MF$rank==4,comparison$q==2,comparison$df_full==16,
 abs(comparison$F-anova(mods$M0,mods$MF)$F[2])<1e-9,
 abs(comparison$p-.054236056264714)<1e-10,
 cat_nested_trace(mods$M0,mods$MI)$df_full==17,
 cat_nested_trace(mods$M0,mods$MS)$df_full==17)
cat("W11A_GROUPS_RUNTIME_PASS: source calculations, not exercise completion\n")
