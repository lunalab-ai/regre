# W06A · 잔차의 분산과 내적·외적 표준화: 수학 보충

주교재 §5.2–5.3을 이해하기 위한 선택 보충입니다. 본 수업에서는 그림과 한 부서의 계산을 먼저 공부하고, 유도는 이 노트에서 다시 확인합니다. §5.7 이후의 정규성 검정·영향력 진단 절차로 범위를 확장하지 않습니다.

## 1. 기호와 조건을 먼저 고정하기

n은 관측 수, p는 설명변수 수, k=p+1은 절편을 포함한 계수 수, ν=n−k는 잔차 자유도입니다. X는 n×k의 완전 열계수 설계행렬입니다. 비가중 OLS, 무오프셋 모형을 사용합니다.

$$
Y=X\beta+\varepsilon,\quad E(\varepsilon\mid X)=0,
\quad\operatorname{Cov}(\varepsilon\mid X)=\sigma^2I_n.
$$

오차의 정규성은 아래 분포를 말하는 단계에서 추가합니다. 평균·공분산 계산 자체에 정규성을 미리 끼워 넣을 필요는 없습니다.

## 2. 잔차를 행렬로 표현하기

$$
\hat\beta=(X^TX)^{-1}X^TY,\qquad
H=X(X^TX)^{-1}X^T,\qquad
\hat Y=HY.
$$

H는 대칭이고 멱등입니다. 즉 Hᵀ=H, H²=H이며, X의 열공간 위로의 직교사영입니다. HX=X이므로 평균 부분은 잔차에서 사라집니다.

$$
e=(I-H)Y=(I-H)X\beta+(I-H)\varepsilon=(I-H)\varepsilon.
$$

따라서 잔차는 원래 오차 자체가 아니라, 적합 과정이 오차를 섞고 일부 성분을 제거한 결과입니다.

## 3. 잔차의 공분산 유도

$$
\begin{aligned}
\operatorname{Cov}(e\mid X)
&=(I-H)\operatorname{Cov}(\varepsilon\mid X)(I-H)^T\\
&=\sigma^2(I-H)(I-H)\\
&=\sigma^2(I-H).
\end{aligned}
$$

마지막 줄은 H²=H를 사용합니다. 대각원소와 비대각원소를 따로 읽으면 다음을 얻습니다.

$$
\operatorname{Var}(e_i\mid X)=\sigma^2(1-h_{ii}),\qquad
\operatorname{Cov}(e_i,e_j\mid X)=-\sigma^2h_{ij}\quad(i\ne j).
$$

따라서 오차가 독립이어도 잔차는 일반적으로 독립이 아닙니다. 잔차 표준편차에 지레값 보정이 필요한 이유도 대각원소에 나타납니다. ‘지레값이 크면 오차 분산이 작다’가 아니라 ‘같은 오차 분산 아래 잔차 분산이 작다’입니다.

## 4. 잔차합0의 정확한 근거

OLS 정상방정식은 Xᵀe=0을 줍니다. X에 모두1인 절편 열이 있으면 그 열과 잔차의 내적이0이므로 잔차합이0입니다.

$$
X^Te=0\quad\Longrightarrow\quad \sum_i e_i=0
\quad\text{(절편 열이 있을 때)}.
$$

이는 모형을 적합한 뒤의 대수적 성질입니다. E(ε∣X)=0은 여러 가능한 표본을 생성하는 과정에 대한 조건부 평균 가정입니다. 둘은 논리적으로 같은 명제가 아닙니다. 절편 없는 모형에서 잔차합0을 무조건 요구하는 것도 잘못입니다.

## 5. 보통·참 규모·내적 표준화

$$
s^2=\frac{e^Te}{\nu},\qquad
z_i=\frac{e_i}{\sigma\sqrt{1-h_{ii}}},\qquad
r_i=\frac{e_i}{s\sqrt{1-h_{ii}}}.
$$

참 σ를 사용하는 z는 위 평균·분산 조건에서 평균0, 분산1을 가집니다. 조건부 정규오차까지 가정하면 각 zᵢ는 표준정규입니다. 그러나 z들의 상호 독립성이 따라오는 것은 아닙니다. 실제 분석에서는 σ가 알려져 있지 않으므로 s를 쓴 내적 표준화잔차를 계산합니다.

내적 r은 분자 eᵢ와 분모 s가 같은 자료를 공유합니다. 따라서 단순히 ‘정규를 추정 표준편차로 나누었으니 자유도ν의 t’라고 말하면 안 됩니다. 독립성 조건이 빠져 있습니다.

## 6. 한 관측을 제외한 분산

hᵢᵢ<1이고 삭제 후 모형도 필요한 계수와 양의 잔차분산을 유지할 때 다음 항등식이 성립합니다.

$$
\mathrm{SSE}_{(i)}=\mathrm{SSE}-\frac{e_i^2}{1-h_{ii}},\qquad
s_{(i)}^2=\frac{\mathrm{SSE}_{(i)}}{\nu-1}.
$$

관측 수가 하나 줄었으므로 자유도도ν에서ν−1로 줄어듭니다. SSE에서 단순히 eᵢ²만 빼지 않는 이유는 나머지 관측에 적합하는 계수도 달라지기 때문입니다. 지레값 항이 그 재적합 효과를 반영합니다.

$$
r_i^*=\frac{e_i}{s_{(i)}\sqrt{1-h_{ii}}}.
$$

분자는 전체 자료의 eᵢ입니다. 삭제 후 모형의 예측을 분자에 쓰는 양은 다음의 삭제예측잔차입니다.

$$
e_{i,\mathrm{pred}}=y_i-\hat y_{i,(-i)}=\frac{e_i}{1-h_{ii}}.
$$

외적 표준화의 정의와 혼합하지 마세요. 두 값은 서로 다른 질문에 답합니다.

## 7. 내적과 외적 값의 변환

eᵢ²/(1−hᵢᵢ)=rᵢ²s², SSE=νs²를 대입합니다.

$$
s_{(i)}^2=s^2\frac{\nu-r_i^2}{\nu-1}.
$$

따라서 양의 분모 범위에서 교재 식5.15를 얻습니다.

$$
r_i^*=r_i\sqrt{\frac{\nu-1}{\nu-r_i^2}}
=r_i\sqrt{\frac{n-p-2}{n-p-1-r_i^2}}.
$$

조건부 정규오차, 완전 열계수, hᵢᵢ<1 등 필요한 조건 아래 외적 표준화잔차의 주변분포는 t₍ν−1₎입니다. 이 사례의 자유도는26입니다. t 분포를 표준정규와 완전히 같거나 정확히 분산1이라고 말하지 않습니다. 자유도26의 분산은26/24이며, 여러 관측의 외적 잔차가 서로 독립이라는 뜻도 아닙니다.

## 8. R로 세 경로 검산하기

```r
fit <- lm(rating~complaints+learning,data=attitude)
e <- residuals(fit); h <- hatvalues(fit); nu <- df.residual(fit)
r <- e/(sigma(fit)*sqrt(1-h))
t_from_r <- r*sqrt((nu-1)/(nu-r^2))
stopifnot(max(abs(r-rstandard(fit)))<1e-10)
stopifnot(max(abs(t_from_r-rstudent(fit)))<1e-10)
i <- 1
minus_i <- lm(rating~complaints+learning,data=attitude[-i,])
t_refit <- e[i]/(sigma(minus_i)*sqrt(1-h[i]))
c(transform=t_from_r[i],refit=t_refit,R=rstudent(fit)[i])
```

직접 식, 삭제 후 재적합, R 기본 함수가 일치해야 합니다. 출력의 미세한 차이는 부동소수점 계산 오차 범위에서 비교합니다. 함수의 결과가 맞다는 사실과 모형의 현실 적합성은 별도로 판단합니다.

## 9. 그림 선택으로 돌아오기

이 유도의 목적은 행렬 계산을 더 많이 하는 데 있지 않습니다. 보통잔차 크기를 비교할 때 왜 관측별 비교 기준이 달라지는지, 외적 표준화에서 왜 분모 추정만 바뀌는지 설명하기 위한 근거입니다. h=1이나 분산0처럼 공식이 성립하지 않는 경우도 결과의 일부로 정직하게 표시합니다.

근거: 주교재 §5.3 및 [R 공식 진단 함수 설명](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/influence.measures.html). 조건부 행렬 유도와 세 경로 검산은 추가 해설입니다.
