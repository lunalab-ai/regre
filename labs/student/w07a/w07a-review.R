# W07A student R. Incomplete exercise code stays in comments.
locations <- c("data","labs/student/w07a/data","../../labs/student/w07a/data")
data_dir <- locations[file.exists(file.path(locations,"review-slr.R"))][1]
if(is.na(data_dir)) stop("Keep the R/QMD and its data folder together.")
source(file.path(data_dir,"review-slr.R"))
demo <- review_slr_data()
demo_result <- review_slr(demo$x,demo$y)
print(demo)

# Explanation example, independent of the exercise questions.
components <- data.frame(x=demo$x,y=demo$y,dx=demo_result$dx,
                         dy=demo_result$dy,product=demo_result$dx*demo_result$dy)
print(components)
print(c(covariance=demo_result$covariance,r=demo_result$correlation,
        b0=demo_result$b0,b1=demo_result$b1,SSE=demo_result$SSE,
        s=demo_result$s,se_b1=demo_result$se_b1))
print(demo_result$ci)
plot(demo$x,demo$y,pch=19,col="#087f8c",xlab="Tasks",ylab="Minutes")
abline(demo_result$b0,demo_result$b1,col="#bb4c23",lwd=2)
segments(demo$x,demo$y,demo$x,demo_result$fitted,col="#bb4c23")

# ## Q43 · 상관 출력과 곡선 관계
# 
# 유형: R · 난이도: 기초 · 출력 예측
# 
# 아래 코드의 출력과 점들의 모양을 예상하시오. cor는 Pearson 상관을 구하며, round(값,6)는 소수6자리까지 반올림한다. 출력만으로 두 변수 사이에 관계가 없다고 말할 수 있는가?
# 
# ```r
# x <- c(-3,-2,-1,0,1,2,3)
# y <- x^2
# print(round(cor(x,y),6))
# plot(x,y)
# ```
# Q43 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q44 · 한 열만 정렬한 오류
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# x와 y는 같은 사람 순서로 측정한 값이다. sort는 원소를 작은 값부터 정렬한다. 다음 코드는 실행되지만 원래 자료의 상관을 바꿔 버린다. 잘못된 줄을 수정하고, 원래 상관과 잘못 계산된 상관을 비교하시오.
# 
# ```r
# x <- c(1,2,3,4)
# y <- c(40,10,30,20)
# r <- cor(x,sort(y))
# print(r)
# ```
# Q44 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q45 · 편차 곱의 합 빈칸
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# sum은 합, mean은 평균이다. Sxy를 직접 계산하도록 ___ 두 곳을 완성하고 결과를 구하시오.
# 
# ```r
# x <- c(1,2,3,4)
# y <- c(1,3,4,8)
# dx <- x - ___
# dy <- y - mean(y)
# Sxy <- sum(dx ___ dy)
# print(Sxy)
# ```
# Q45 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q46 · 공분산에서 상관까지
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# n=5, Sxy=12, Sxx=10, Syy=40이다. 아래 빈칸 두 개를 완성해 표본공분산과 상관을 구하시오. sqrt는 제곱근이다.
# 
# ```r
# n <- 5; Sxy <- 12; Sxx <- 10; Syy <- 40
# sxy <- Sxy / ___
# r <- Sxy / sqrt(___)
# print(c(covariance=sxy,correlation=r))
# ```
# Q46 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q47 · 결측을 각각 빼면 생기는 오류
# 
# 유형: R · 난이도: 통합 · 에러 찾기
# 
# is.na는 결측이면TRUE, !는 반대, &는 두 조건이 모두TRUE인 위치를 뜻한다. 두 열에서 결측을 따로 제거한 코드의 문제를 찾고, 같은 관측에서 두 값이 모두 있는 쌍만 사용하도록 수정하시오.
# 
# ```r
# x <- c(1,NA,3,4)
# y <- c(2,4,NA,8)
# x2 <- x[!is.na(x)]
# y2 <- y[!is.na(y)]
# print(cor(x2,y2))
# ```
# Q47 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q48 · 단위를 바꾼 출력
# 
# 유형: R · 난이도: 적용 · 출력 예측
# 
# cov와 cor는 각각 표본공분산과 상관을 반환한다. 아래 두 출력 벡터를 구하고 시간 단위를분에서초로 바꿀 때 유지되는 값을 설명하시오.
# 
# ```r
# x <- c(1,2,3)
# y <- c(2,4,6)
# print(c(cov=cov(x,y),r=cor(x,y)))
# print(c(cov=cov(x,60*y),r=cor(x,60*y)))
# ```
# Q48 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q49 · 기울기와 절편 빈칸
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# 아래 코드가 기본 산술로 OLS 계수를 계산하도록 두 빈칸을 채우시오. 여기서 x,y는 이번 문항 안에서 새로 정의된다.
# 
# ```r
# x <- c(1,2,3,4)
# y <- c(1,3,4,8)
# Sxx <- sum((x-mean(x))^2)
# Sxy <- sum((x-mean(x))*(y-mean(y)))
# b1 <- ___
# b0 <- mean(y) - ___
# print(c(intercept=b0,slope=b1))
# ```
# Q49 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q50 · 적합값과 잔차 빈칸
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# 아래 식의 계수는 이미 주어졌다. 예측값과 잔차를 계산하도록 빈칸을 채우고 마지막 출력의 네 값을 구하시오.
# 
# ```r
# x <- c(1,2,3,4); y <- c(1,3,4,8)
# b0 <- -1.5; b1 <- 2.2
# yhat <- ___
# e <- ___
# print(round(e,3))
# ```
# Q50 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q51 · 제곱 위치의 조용한 오류
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 아래 코드는 오류 메시지 없이 숫자를 출력하지만 SSE가 아니다. 잘못된 식을 고쳐 SSE를 구하고, 원래 코드가 왜0을 내는지 설명하시오.
# 
# ```r
# e <- c(-2,-1,1,2)
# SSE <- sum(e)^2
# print(SSE)
# ```
# Q51 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q52 · 반응변수를 뒤집은 코드
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# lm(y ~ x)는 왼쪽 y를 오른쪽 x로 설명하는 절편 포함 회귀이다. coef는 절편과 기울기를 돌려준다. “공부시간 hours로 점수 score를 설명”하려는 코드가 아래와 같다. 모형 식을 고치고 수정 전후 기울기의 단위를 설명하시오.
# 
# ```r
# hours <- c(1,2,3,4)
# score <- c(3,5,6,10)
# m <- lm(hours ~ score)
# print(coef(m))
# ```
# Q52 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q53 · 오차분산과 표준편차
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# n=8인 절편 포함 단순회귀에서 SSE=54이다. 분산 추정값과 표준편차 추정값을 구하도록 두 빈칸을 완성하시오.
# 
# ```r
# n <- 8; SSE <- 54
# s2 <- SSE / ___
# s <- ___
# print(c(variance=s2,sd=s))
# ```
# Q53 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q54 · 기울기 SE의 제곱근 오류
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 기울기 표준오차 공식은 s/√Sxx이다. 아래 코드의 문제를 고치고 결과를 구하시오. 이때 s의 단위는점, X의 단위는시간이다.
# 
# ```r
# s <- 3; Sxx <- 25
# se_b1 <- s/Sxx
# print(se_b1)
# ```
# Q54 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q55 · 임의의 귀무기울기
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# b1은 추정 기울기, null은 귀무기울기, se는 표준오차이다. t통계량 빈칸을 채우고 값을 해석하시오.
# 
# ```r
# b1 <- 1.8; null <- 1; se <- 0.4
# t_value <- ___
# print(t_value)
# ```
# Q55 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q56 · 양측 p값의 두 꼬리
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# pt(q,df)는 자유도df의 t분포에서 q이하일 누적확률이다. abs는 절댓값이다. 관측 t=−2.5, df=8일 때 양측 p값을 계산하려는 코드에서 빠진 부분을 고치시오.
# 
# ```r
# t_value <- -2.5; df <- 8
# p_two <- pt(-abs(t_value),df=df)
# print(round(p_two,6))
# ```
# Q56 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q57 · 계수표의 열 읽기
# 
# 유형: R · 난이도: 적용 · 출력 예측
# 
# 다음 출력에서 각 열 이름의 뜻이 주어져 있다. n=10, 귀무기울기0에 대한 양측검정이다. t값이 Estimate/SE와 일치하는지 확인하고5%수준에서 X계수 결론을 쓰시오. coef나 객체 내부구조를 암기할 필요는 없다.
# 
# ```r
# # 계수표: Estimate=추정값, Std.Error=표준오차
# #          Estimate  Std.Error  t value  Pr(>|t|)
# # X           2.00       0.50     4.00    0.0040
# # 마지막 열은 양측 p값이다.
# ```
# Q57 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q58 · 기울기 구간 빈칸
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# c(-1,1)은 두 부호를 담은 벡터이다. 아래 코드가95% 계수 구간의 하한·상한을 만들도록 빈칸을 완성하시오. 임계값은 주어진2.306을 그대로 사용한다.
# 
# ```r
# b1 <- 1.5; se <- 0.3; critical <- 2.306
# ci <- b1 + c(-1,1) * ___
# print(ci)
# ```
# Q58 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q59 · 구간에 귀무값이 포함되는가
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# ci[1]은 하한, ci[2]는 상한이다. 아래 빈칸에 비교 연산자를 넣어 구간[−0.2,1.4]가 귀무값0을 포함하는지 판정하고, 같은95% 구간/5% 양측검정의 결론을 쓰시오.
# 
# ```r
# ci <- c(-0.2,1.4); null <- 0
# contains <- (ci[1] ___ null) & (null ___ ci[2])
# print(contains)
# ```
# Q59 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

# ## Q60 · confint 결과와 단위
# 
# 유형: R · 난이도: 통합 · 출력 예측
# 
# confint(m,level=0.95)는 각 회귀계수의95% 구간을 반환한다. 다음은 Minutes(분)를 Units(개)로 설명한 모형에서 기울기 행만 보인 출력이다. 두 숫자를 해석하고, Units를 dozens=Units/12로 바꿨을 때 새 기울기 구간을 구하시오. 동일한 적합을 다른 단위로 표시한다.
# 
# ```r
# #                2.5 %    97.5 %
# # Units          14.40     16.60
# # 단위: 분/개. 표시된 끝점을 정확한 값으로 취급한다.
# ```
# Q60 TODO: 위 문제의 코드를 직접 완성하세요.
# 실행 전 예상 / 출력 / 이론 설명을 기록하세요.

my_result <- review_slr(demo$x,demo$y,level=.95,null=0)
print(c(slope=my_result$b1,t=my_result$t,p=my_result$p))
