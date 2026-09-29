# W05B · 수학과 제약 계산 보충

본문의 질문을 행렬과 계산으로 확인하는 선택 보충입니다. 주교재 §4.6–4.11을 벗어난 새 진단 단원을 추가하지 않습니다. p는 설명변수 수, k=p+1은 절편을 포함한 계수 수, n은 관측 수입니다. X는 n×k 완전 열계수 설계행렬이고 첫 열은 1입니다.

## 1. 중심화의 불변성은 재매개화에서 나온다

원래 모형에 xj=xcj+평균xj를 대입하면 다음과 같습니다.

$$
\beta_0+\sum_j\beta_jx_j
=\left(\beta_0+\sum_j\beta_j\bar x_j\right)+\sum_j\beta_jx^c_j.
$$

설명변수의 원점만 바꾸면 같은 예측함수 집합을 다른 절편으로 표현합니다. 따라서 동일한 최소 SSE와 적합값을 얻습니다. 절편을 포함하지 않는 모형에서는 이동으로 생긴 상수항을 흡수할 곳이 없으므로 이 주장을 그대로 쓰지 못합니다. X와 Y를 모두 표준화하면 원래 예측은 평균y+표준편차y×표준화 예측으로 복원합니다.

$$
\hat\beta_j^{(z)}=\hat\beta_j\frac{s_j}{s_y},\qquad
\hat\beta_0=\bar y-\sum_j\hat\beta_j\bar x_j.
$$

평균과 표준편차는 학습 자료에서 계산한 값이어야 합니다. 상호작용·비선형 항을 포함할 때에는 모든 관련 항의 변환을 함께 고려해야 하며, 벌점이 있는 추정법의 척도 효과까지 이 OLS 결과로 일반화하지 않습니다.

## 2. 최소제곱추정량의 평균과 분산

모형 y=Xβ+ε에서 OLS 식에 대입합니다.

$$
\hat\beta=(X^{\mathsf T}X)^{-1}X^{\mathsf T}y
=\beta+(X^{\mathsf T}X)^{-1}X^{\mathsf T}\varepsilon.
$$

X를 조건으로 E(ε|X)=0이면 바로 E(β̂|X)=β입니다. 오차 공분산이 σ²I이면 선형변환의 공분산 공식으로 다음을 얻습니다.

$$
\operatorname{Var}(\hat\beta\mid X)
=(X^{\mathsf T}X)^{-1}X^{\mathsf T}(\sigma^2 I)X(X^{\mathsf T}X)^{-1}
=\sigma^2(X^{\mathsf T}X)^{-1}.
$$

이 계산에는 정규분포를 쓰지 않았습니다. s²=SSE/(n−k)로 σ²를 추정하면 `vcov(fit)`가 s²(XᵀX)⁻¹을 반환하고, 대각 원소의 제곱근이 계수별 SE입니다. 오차분산 s² 하나와 계수 공분산행렬을 구별하세요.

## 3. BLUE의 비교 대상과 범위

다른 선형 불편추정량을 Ay라 쓰면 AX=I여야 합니다. A=(XᵀX)⁻¹Xᵀ+D라고 두면 DX=0입니다. 따라서 공분산의 차이는 다음과 같습니다.

$$
\operatorname{Var}(Ay\mid X)-\operatorname{Var}(\hat\beta\mid X)
=\sigma^2 DD^{\mathsf T}\succeq0.
$$

임의 벡터 v에 대해 vᵀDDᵀv=‖Dᵀv‖²≥0이므로 다른 선형 불편추정량의 분산을 더 작게 만들 수 없다는 결론입니다. 모든 비선형·편향 추정량까지 포함한 최적성, 예측 MSE의 절대 우월성, 개별 표본의 정확성을 주장한 정리가 아닙니다.

## 4. 정규성은 t와 F 분포에서 사용한다

정규오차라면 β̂는 다변량 정규분포이고, SSE/σ²는 자유도 n−k의 카이제곱분포이며 β̂와 독립입니다. 분산을 모르는 정규 추정량을 독립적인 분산 추정값으로 표준화하여 t분포를 얻습니다.

$$
\frac{\hat\beta_j-\beta_{j,0}}{s\sqrt{[(X^{\mathsf T}X)^{-1}]_{jj}}}\sim t_{n-k}.
$$

따라서 t검정과 계수 신뢰구간은 같은 표준오차와 자유도를 사용합니다. 이 수업의 정확한 소표본 결과를 비정규·이분산 자료에 가정 확인 없이 그대로 적용했다고 말하지 않습니다.

## 5. R과 R²의 연결

절편 포함 OLS의 잔차 e는 적합값 ŷ 및 상수 열과 직교합니다. y−평균y=(ŷ−평균y)+e이므로 제곱합이 더해집니다. 또한 표본 공분산의 분자는 다음과 같습니다.

$$
\sum_i(y_i-\bar y)(\hat y_i-\bar y)
=\sum_i(\hat y_i-\bar y)^2.
$$

적합값이 비상수이면 cor(y,ŷ)=√(SSR/SST)=√R²입니다. 수정 R²는 자유도당 제곱합의 비를 1에서 뺀 지표라서 동일한 상관제곱으로 표현되지 않습니다.

## 6. 일반 선형가설 · Lβ=r

L은 q×k 행렬이고 각 행이 하나의 독립 제약입니다. 계수 순서는 반드시 `names(coef(fit))`와 맞춰야 합니다. 예를 들어 두 변수 모형의 순서는 절편, complaints, learning입니다.

$$
F=\frac{(L\hat\beta-r)^{\mathsf T}
[L\widehat{\operatorname{Var}}(\hat\beta)L^{\mathsf T}]^{-1}
(L\hat\beta-r)}{q}\sim F_{q,n-k}\quad\text{under }H_0.
$$

`vcov()`는 이미 s²를 포함하므로 이 식에 s²를 다시 나누지 않습니다. 제약이 한 개면 이차형식은 표준화한 차이의 제곱이어서 F=t²가 됩니다.

```r
fit2 <- lm(rating~complaints+learning, data=attitude)
L <- matrix(c(0,1,-1), nrow=1)
delta <- as.vector(L %*% coef(fit2))
variance <- as.numeric(L %*% vcov(fit2) %*% t(L))
F_equal <- delta^2/variance
pf(F_equal, 1, df.residual(fit2), lower.tail=FALSE)
```

β1−β3의 분산은 Var(β̂1)+Var(β̂3)−2Cov(β̂1,β̂3)입니다. 두 표준오차를 더하거나 제곱만 더하면 공분산 항을 놓칩니다. 이 자료에서 두 기울기의 추정 공분산은 약 −0.0095023입니다.

## 7. 동일성 제약을 축소모형으로 검산

```r
equal_model <- lm(rating~I(complaints+learning), data=attitude)
anova(equal_model, fit2)
```

축소모형은 절편과 공통 기울기, 총2개 계수이고 완전모형은3개입니다. q=1, 분모 자유도27입니다. F≈3.657224, p≈0.066490으로 위 일반 선형가설과 일치합니다. 두 모형의 반응과 관측행이 같기 때문에 이 `anova()` 비교가 유효합니다.

## 8. 합 제약 · 원래 반응으로 복원하기

```r
sum_model <- lm(I(rating-learning)~I(complaints-learning), data=attitude)
fitted_original_y <- fitted(sum_model)+attitude$learning
SSE_reduced <- sum((attitude$rating-fitted_original_y)^2)
F_sum <- ((SSE_reduced-deviance(fit2))/1)/
         (deviance(fit2)/df.residual(fit2))
c(F=F_sum, p=pf(F_sum,1,27,lower.tail=FALSE))
```

원래 y로 계산한 축소 SSE≈1329.547455, F≈1.611813, p≈0.215071입니다. 일반 선형가설에서는 L=(0,1,1), r=1을 사용합니다. `anova(sum_model,fit2)`는 반응변수가 달라 올바른 비교가 아닙니다. 소프트웨어 경고를 숨기지 말고 무엇을 비교했는지 바로잡아야 합니다.

동일성과 합을 동시에 제약할 때는 L의 두 행을 (0,1,−1), (0,1,1), r=(0,1)로 둡니다. 두 기울기는 제약 아래에서 각각0.5가 되고 절편만 추정하므로 q=2입니다. 이 동시 검정의 F≈2.3126, p≈0.1183 역시 비기각이 값의 증명이라는 뜻은 아닙니다.

## 9. 평균과 새 관측의 분산

새 조건 x0에서 추정 평균은 x0ᵀβ̂입니다. 선형변환의 분산으로 평균 추정 분산 σ²h0를 얻습니다. 새 부서의 오차 ε0가 학습 오차와 독립이고 같은 분산 σ²를 갖는다면 새 관측 예측오차에 그 분산이 추가됩니다.

$$
\operatorname{Var}(\hat y_0\mid X)=\sigma^2h_0,\qquad
\operatorname{Var}(y_0-\hat y_0\mid X)=\sigma^2(1+h_0).
$$

평균 조건에서는 절편 포함 OLS의 h0=1/n입니다. 두 변수 모형의 n=30, s≈6.816779, t0.975,27≈2.05183을 넣으면 평균 CI 폭≈5.107285, 새 관측 PI 폭≈28.436159입니다. 관측 단위는 부서이며 새 직원 개인의 응답 범위가 아닙니다.

```r
x0 <- c(1, mean(attitude$complaints), mean(attitude$learning))
X <- model.matrix(fit2)
h0 <- as.numeric(t(x0) %*% solve(crossprod(X), x0))
c(h0=h0, mean_SE=sigma(fit2)*sqrt(h0), new_SE=sigma(fit2)*sqrt(1+h0))
```

이 역행렬 표현은 작은 예에서 이론을 검산하기 위한 것입니다. 일반 회귀 적합은 `lm()`의 수치 알고리즘을 사용합니다. 신뢰수준·오차분산·설계 위치가 구간 폭에 각각 어떤 역할을 하는지 분리해서 읽으세요.

## 참고자료

주교재 §4.6–4.11의 식과 제약 사례를 R 내장 attitude로 검산했습니다. [R vcov](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/vcov.html), [anova.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.lm.html), [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), 2026-09-29 확인. 재매개화와 가정 구분, 잘못된 반응 비교의 교정은 수업용 추가 해설입니다.
