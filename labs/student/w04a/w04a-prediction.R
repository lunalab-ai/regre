# ---
# title: "W04A · 예측·적합성·특수 회귀모형 실험실"
# lang: ko
# format:
#   html:
#     toc: true
# execute:
#   warning: false
#   error: false
# ---
# 
# ## 1. 같은 자료와 공통 함수 준비
# 
# 온라인은 설치·로그인 없이 실행한다. 다운로드판은 저장소 ZIP을 풀어 `data` 폴더를 함께 유지한다. `.R`은 이 QMD의 코드와 연습 안내를 추출한 파일이다. 미완성 연습 셀을 건너뛰어도 기본 흐름은 실행된다. 편집 후에는 **내 R 코드 다운로드**로 보관한다.
# 
# `source()`는 동봉한 함수 정의를 읽는다. `read.table(...,header=TRUE)`는 첫 행을 열 이름으로 읽는다. 자료는 지난 시간과 같은 수리 14건이며 열은 `Units`(부품 수), `Minutes`(분)이다. 새 업로드·네트워크 다운로드·패키지 설치는 하지 않는다.

locations <- c("data","../../labs/student/w04a/data","labs/student/w04a/data")
data_dir <- locations[file.exists(file.path(locations,"prediction-tools.R"))][1]
stopifnot(!is.na(data_dir))
source(file.path(data_dir,"slr-tools.R"))
source(file.path(data_dir,"prediction-tools.R"))
repair <- read.table(file.path(data_dir,"Computer.Repair.txt"),header=TRUE)
head(repair)

# 공통 코드는 공개 고정 버전 `2026-fall-w04a`의 동봉 사본이다. [fit_repair 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/slr-tools.R#L7)는 결측·무한값 없는 숫자 열 `Units/Minutes`를 가진 3행 이상의 표를 받아 절편 포함 `lm`을 적합한다. Units에 변화가 있어야 한다. 반환은 계수·적합값·잔차를 보관하는 모형이며 입력을 바꾸지 않는다. 손실은 수직 잔차제곱합이다.
# 
# [prediction_intervals 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-tools.R#L12)는 적합된 모형과 숫자 벡터 `units`를 받아 구간을 계산한다. `level=.95`, `interval="confidence"`가 기본이다. `"prediction"`은 새 개별 관측 구간이다. 반환은 입력 순서대로 `Units/fit/lower/upper/width/kind/level/extrapolation` 열을 가진 표다. 구간·폭의 단위는 분, 범위 밖 여부는 TRUE/FALSE다. 새 적합이나 다운로드는 없다. [전체 API](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-api.md)를 함께 읽는다.

fit <- fit_repair(repair)
coef(fit)
mean4 <- prediction_intervals(fit,4)
new4 <- prediction_intervals(fit,4,interval="prediction")
rbind(mean4,new4)

# 두 점예측은 약 66.197분이다. 평균반응 구간과 새 관측 구간의 폭이 다른 것은 새 관측에 추가 오차가 있기 때문이다. `predict()`의 표준 출력 열은 `fit/lwr/upr`이고, 공통 함수는 이를 읽기 쉽게 `fit/lower/upper`로 바꾼다.
# 
# ## 2. L1: 같은 x에서 질문 바꾸기
# 
# **목표:** 평균과 개별 관측을 구별한다. x=8일 때 두 구간을 계산하도록 빈칸을 채운다. **힌트:** 공식 [predict.lm 문서](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html)의 `newdata`, `interval`을 확인한다. **자가 점검:** 두 행의 점예측은 같은가? 어느 구간이 넓으며 그 추가 분산은 어디에서 오는가?

# #| eval: false
# newdata_try <- data.frame(Units=...)
# mean_try <- predict(fit,newdata=newdata_try,interval=...)
# single_try <- predict(fit,newdata=newdata_try,interval=...)
# rbind(mean_try,single_try)

# ## 3. 구간 폭과 외삽 탐색

positions <- c(4,6,10,11)
interval_comparison <- rbind(prediction_intervals(fit,positions),
                             prediction_intervals(fit,positions,interval="prediction"))
interval_comparison
grid <- prediction_intervals(fit,seq(1,11,length.out=101))
plot(Minutes~Units,data=repair,pch=19,xlim=c(1,11),ylim=c(0,195),
     xlab="Units",ylab="Minutes",main="Pointwise mean-response CI")
lines(grid$Units,grid$fit,col="#2864b4",lwd=2)
lines(grid$Units,grid$lower,col="#168c82",lty=2)
lines(grid$Units,grid$upper,col="#168c82",lty=2)
abline(v=10,col="#d25340",lty=3)

# 선들은 점별 신뢰구간을 이어 놓은 것이다. 직선 전체를 동시에 95%로 덮는 신뢰대는 아니다. 관측 범위는 1–10개이고 11개는 외삽이다. 계산이 나온다고 그 위치에서 선형성·분산 가정이 검증된 것은 아니다.
# 
# ## 4. L2: 예측 데이터와 구간 디버깅
# 
# **목표:** 실행 여부와 질문에 맞는 계산을 구별한다. 아래 코드는 ‘부품 4개를 수리하는 새 작업 한 건’의 구간을 구하려는 코드다. 변수명과 구간 종류를 고친다. **힌트:** R의 대소문자는 다르며 `newdata`의 열 이름은 모형의 예측변수와 같아야 한다. **자가 점검:** 경고 없이 1행 3열이 나오는가? 평균 구간보다 넓은가? 오류·경고가 없더라도 구간의 대상이 맞는지 설명한다.

# #| eval: false
# broken_try <- predict(fit,newdata=data.frame(units=4),interval="confidence")
# broken_try

# ## 5. 적합성의 기준 확인
# 
# [regression_fit_summary 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-tools.R#L38)는 가중치·offset 없는 완전 계수 `lm`을 받아 한 행 요약표를 만든다. `n/p/df`는 관측·추정계수·잔차 자유도, `SSE/SST_centered/SSR_centered`는 분², `RSE`는 분이다. `R_squared`의 기준은 절편이 있으면 평균(`mean`), 없으면 0(`zero`)이다. `R_squared_centered`는 항상 평균 기준이며 음수도 가능하다. `decomposition_valid`는 중심 제곱합 분해의 절편 조건을 나타낸다. 0인 분모의 비율은 NA다. 모형을 다시 적합하지 않는다.

fit_summary <- regression_fit_summary(fit)
fit_summary
cor(repair$Units,repair$Minutes)^2

# ### L3: 제곱합을 직접 조립
# 
# **목표:** 요약표의 숫자를 원래 정의로 설명한다. **힌트:** SST는 관측값과 평균, SSR은 적합값과 평균, SSE는 관측값과 적합값의 차이다. **자가 점검:** 세 제곱합의 단위, 분해 등식, 두 가지 R² 계산이 일치하는지 확인한다. R²가 큰 것으로 인과관계가 증명되는지도 설명한다.

# #| eval: false
# y_try <- repair$Minutes
# yhat_try <- fitted(fit)
# sst_try <- ...
# ssr_try <- ...
# sse_try <- ...
# r2_try <- ...
# c(SST=sst_try,SSR=ssr_try,SSE=sse_try,R2=r2_try)

# ## 6. L4: 원점을 지나게 하면 무엇이 바뀌는가?

origin_fit <- lm(Minutes~0+Units,data=repair)
origin_summary <- regression_fit_summary(origin_fit)
rbind(intercept=fit_summary,origin=origin_summary)

# **목표:** 서로 다른 기준의 R² 비교를 피한다. **질문:** (a) 자유도와 잔차합이 어떻게 달라졌는가? (b) R의 원점 모형 R²가 더 크다는 이유로 더 좋은 모형이라고 선택할 수 있는가? (c) 같은 평균 기준 R²와 SSE를 비교하면 무엇이 보이는가? (d) Units=0에서 수리시간=0이어야 한다는 제약을 이 자료만으로 확정할 수 있는가? **힌트:** 실제 Units 범위와 `baseline` 열을 본다. **자가 점검:** 절편의 p값이 크다는 이유만으로 삭제하지 않고 자료 수집·과학적 의미를 함께 설명한다.
# 
# ## 7. L5: 평균도 회귀모형으로 표현

mean_fit <- lm(Minutes~1,data=repair)
coef(mean_fit)
mean(repair$Minutes)

# **목표:** 절편만 모형과 대응표본 검정을 연결한다. 아래 자료는 설명용 합성 점수다. 같은 6대 장비의 개선 전·후 처리시간으로 생각하되 실제 실험 자료가 아니다. 차이를 `before-after`로 정한다. 두 빈칸을 채워 평균 감소량을 추정한다. **힌트:** 절편만 모형은 `~1`; `t.test()`는 기본적으로 평균 0에 대한 양측 검정이다. **자가 점검:** lm의 절편 t와 t.test의 t가 같은가? 자유도는? 차이의 부호를 뒤집으면 t·양측 p·구간은 각각 어떻게 되는가? 이 합성 예로 현실의 개선 효과를 주장할 수 있는가?

# #| eval: false
# before_try <- c(9,11,10,12,13,8)
# after_try <- c(8,9,6,9,8,6)
# d_try <- ...
# paired_fit_try <- lm(...)
# summary(paired_fit_try)
# t.test(before_try,after_try,paired=TRUE,mu=0,alternative="two.sided")

# ## 8. L6: 누적 앱에 ‘구간 종류’ 입력을 직접 연결
# 
# [누적 앱 코드 편집기](https://lunalab-ai.github.io/regre/apps/w04a/edit/index.html)를 연다. 다운로드판은 Shiny가 있는 기존 환경에서 `app/app.R`을 실행한다. 새 ‘예측과 구간’·‘적합성 비교’ 탭과 이전 네 탭을 사용한다.
# 
# **목표:** 입력 → 반응형 설정 → 공통 함수 → 표·그림의 연결을 직접 바꾼다. 먼저 x=4에서 평균/개별 구간을 비교하고 x=11, 신뢰수준 99%로 바꾸어 결과를 관찰한다. **직접 조립:** `# L6-UI` 아래에 새 `selectInput()`을 추가하되 ID는 `kind_custom`, 선택값은 `confidence/prediction`, 기본값은 `prediction`으로 정한다. `# L6-SERVER` 아래 설정 함수의 `input$interval_kind` 두 곳을 `input$kind_custom`으로 바꾼다. 기존 입력은 남겨 둔다. **Re-run app** 후 새 입력을 바꾼다.
# 
# **힌트:** 쉼표와 따옴표, UI와 서버의 ID 일치를 확인한다. 기본 `interval_kind`의 `selectInput()`을 구조 예시로 삼는다. **자가 점검:** 새 입력으로 종류를 바꾸면 표·그림·안내가 함께 바뀌는가? 점예측은 같은가? 이전 입력은 이제 결과를 바꾸는가? ‘첫 회귀 예측’과 ‘계수 추론’ 기능이 그대로 동작하는가?
# 
# ## 9. 저장·재시작·기본 결과 확인
# 
# **내 R 코드 다운로드** 후 **R 세션 다시 시작**을 누르고 기본 셀을 위에서부터 다시 실행한다. 저장된 편집 내용과 R 객체는 서로 다르다. 기본 셀은 연습용 변수에 의존하지 않는다.

stopifnot(nrow(repair)==14,df.residual(fit)==12,
          abs(mean4$fit-66.1967418546366)<1e-8,
          new4$width>mean4$width,
          abs(fit_summary$R_squared-cor(repair$Units,repair$Minutes)^2)<1e-10,
          origin_summary$baseline=="zero",df.residual(mean_fit)==13)

# 참고: 주교재 3.8–3.12 및 R 공식 [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), [summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html), [lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), [t.test](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html).
