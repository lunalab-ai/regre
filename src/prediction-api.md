# 예측·적합성 공통 API · 2026-fall-w04a

Base R만 사용한다. 동봉 사본을 `source()`로 읽으며 네트워크 다운로드·패키지 설치·원자료 변경은 없다. 기존 `fit_repair()`와 계수 추론 API는 그대로 유지된다. 일반적인 회귀 계산을 여러 실습과 앱에서 공유하는 함수다.

## 모형 준비

[fit_repair 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/slr-tools.R#L7)는 숫자 `Units`(개), `Minutes`(분) 열을 가진 데이터프레임에서 `Minutes ~ Units`를 적합한다. 3행 이상이고 결측·무한값이 없으며 X가 변해야 한다. 손실은 수직 잔차제곱합이다. `lm` 객체의 계수·적합값·잔차는 이후 계산에 재사용한다. 전체 설명은 [앞선 API](slr-api.md)에 있다.

## prediction_intervals

[함수 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-tools.R#L12)

```r
prediction_intervals(model, units, level=.95, interval="confidence")
```

`model`은 완전 계수·양의 잔차분산·양의 잔차 자유도를 갖는, 가중치와 offset이 없는 절편 포함 `lm(Minutes ~ Units)`다. `units`는 길이 1 이상인 유한 숫자 벡터(개)다. `level`은 0과 1 사이의 숫자 하나다. `interval`은 `confidence` 또는 `prediction`을 정확히 지정한다. 부분 문자열은 허용하지 않는다.

`confidence`는 평균반응, `prediction`은 독립인 새 관측 한 건의 구간이다. 모형의 선형성·독립·등분산·정규오차 가정이 자동 검증되는 것은 아니다. 각 위치의 점별 구간이며 동시 신뢰대가 아니다.

입력 순서대로 한 위치당 한 행인 데이터프레임을 반환한다.

| 열 | 의미·단위 |
|---|---|
| Units | 입력한 예측 위치, 개 |
| fit | 점예측, 분 |
| lower / upper | 구간 하한 / 상한, 분 |
| width | 상한-하한, 분 |
| kind | confidence / prediction |
| level | 사용한 신뢰수준 |
| extrapolation | 학습 X의 최솟값·최댓값 범위 밖이면 TRUE |

```r
fit <- fit_repair(repair)
prediction_intervals(fit,4)
```

수업의 14행 자료에서는 점예측 약 66.197분, 95% 평균반응 구간 약 [62.363,70.031]분이다. `interval="prediction"`이면 중심은 같고 구간은 약 [53.839,78.554]분이다. 이 함수는 모델을 다시 적합하지 않으며 입력값을 바꾸지 않는다. 관측 범위 밖을 표시하지만 예측 자체를 금지하지 않는다. 밖에서도 계산된다는 사실이 타당성을 보장하지 않는다.

## regression_fit_summary

[함수 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-tools.R#L38)

```r
regression_fit_summary(model)
```

숫자 단일 반응변수의 완전 계수 `lm`을 받는다. 잔차 자유도가 양수이고 가중치·offset이 없어야 한다. 설명변수 하나인 모형 외에도 이 조건을 만족하는 OLS에 사용할 수 있으나 이 차시는 세 가지 단순 모형을 다룬다. 반환은 한 행 데이터프레임이다.

| 열 | 정의 |
|---|---|
| n / p / df | 실제 모형 행 수 / 추정계수 수 / 잔차 자유도 |
| SSE | 잔차제곱합, 반응 단위² |
| SST_centered | 관측값과 표본평균 차이의 제곱합 |
| SSR_centered | 적합값과 표본평균 차이의 제곱합 |
| RSE | sqrt(SSE/df), 반응 단위 |
| residual_sum | 잔차합, 반응 단위 |
| baseline | 절편이 있으면 mean, 없으면 zero |
| R_squared | 절편 유무에 따른 기본 기준의 1-SSE/분모 |
| R_squared_centered | 항상 관측값의 평균 기준으로 계산한 1-SSE/SST |
| decomposition_valid | 절편 포함 OLS의 중심 제곱합 분해 조건 충족 여부 |

0인 분모의 비율은 NA다. 원점 모형의 `SSR_centered`를 계산할 수는 있지만 SST=SSR+SSE를 뜻하지 않는다. 중심 R²는 원점 제약하에서 음수도 가능하다. `R_squared`의 분모는 [summary.lm 공식 문서](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html)와 같다.

```r
regression_fit_summary(fit)
```

수업 자료의 기본 모형은 n=14, p=2, df=12, SSE≈348.848, baseline=mean, R²≈0.987437이다. 모형 재적합·다운로드·파일 쓰기 등 부작용은 없다. 모형을 비교할 때 자료와 반응 단위, R² 기준이 같은지 먼저 확인한다.
