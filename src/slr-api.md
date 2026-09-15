# 단순선형회귀 공통 함수 · W03B

이 차시의 동봉 함수는 공개 고정 버전 `2026-fall-w03b`의 `src/slr-tools.R`와 같은 바이트다. 온라인 R과 Shiny는 동봉 사본을 `source()`로 읽으므로 GitHub에서 매번 내려받지 않는다. 이전 API는 그대로 유지한다.

## 적합과 추론은 다른 단계다

- [fit_repair 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w03b/src/slr-tools.R#L7): `data.frame`의 숫자형 `Units`(개), `Minutes`(분) 열을 받는다. 3행 이상, 유한값, 변화하는 Units가 필요하다. 추가 열은 사용하지 않는다. 반환은 절편 포함 `lm` 객체이며 관측 순서를 유지한다. 최소제곱으로 계수를 추정한다. 결측을 임의로 삭제하지 않고 오류를 낸다.
- [coefficient_inference 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w03b/src/slr-tools.R#L29): 적합된 `Minutes ~ Units` 모형, `level=0.95`(0과 1 사이), `null_slope=0`(분/개)을 받는다. 절편의 귀무값은 항상 0이다. 모형을 새로 적합하지 않는다. 정확한 t 추론은 선형 평균·독립·등분산·정규오차 가정에 의존한다.

반환은 절편, 기울기 순서의 2행 데이터프레임이다.

| 열 | 의미 |
|---|---|
| term | 계수 이름 |
| estimate, se | 계수 추정값과 표준오차 |
| df, null | 잔차 자유도와 비교하는 귀무값 |
| t_value, p_value | 양측 t 통계량과 p값 |
| lower, upper | 해당 신뢰수준에서의 계수별 구간 |
| reject | p값이 1-level보다 작은지 나타내는 논리값 |

계수·SE·구간은 절편이면 분, 기울기이면 분/개 단위다. 원자료를 바꾸거나 패키지를 설치하거나 파일을 다운로드하지 않는다. 잔차 변동이 사실상 0이면 추론을 중단하고 이유를 알린다. 구간은 두 계수 각각의 구간이지 두 계수의 동시 구간이나 수리시간 예측구간이 아니다.

```r
source("src/slr-tools.R")
example_data <- data.frame(Units = 1:4, Minutes = c(2,4,4,6))
example_fit <- fit_repair(example_data)
coef(example_fit)  # 절편 1, 기울기 1.2 (합성 계산 예)
coefficient_inference(example_fit)
```

`source(path)`는 경로 문자열의 R 함수 정의를 현재 환경에 읽어들이는 단계다. 이 호출만으로 모형을 적합하지 않는다. 실제 적합은 `fit_repair()`를 호출할 때 일어난다. 예제 자료의 단위는 설명용 가정이며 실제 수리자료가 아니다.
