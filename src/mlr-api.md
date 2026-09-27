# W05A 공통 R 함수 안내

고정 버전: `2026-fall-w05a-v2`. 모든 계산은 base R이며 패키지 설치·네트워크 호출·입력 데이터 수정이 없습니다. 그림 함수만 현재 그래픽 장치에 그림을 출력합니다. `source()`는 정의를 읽고, `fit_attitude()`가 `lm()`을 호출하여 추정합니다.

| 함수와 정의 바로가기 | 입력 | 반환과 단위 | 읽을 때 확인할 부분 |
|---|---|---|---|
| [validate_numeric_frame 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L6) | `표, 필수 열 이름` | 원본 표를 invisibly 반환 | 3행 이상·숫자·유한값 검사, NA/Inf는 오류 |
| [four_points 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L15) | `없음` | 합성 x/y 4행 표 | 실제 조사자료가 아님 |
| [fit_attitude 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L21) | `data=attitude, predictors=c("complaints","privileges")` | 절편 포함 lm | character(0)은 평균 모형, 특이 설계·자유도 부족 오류 |
| [ss_decomposition 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L37) | `절편 포함·비가중·offset 없는 lm` | list(points, summary) | 편차는 %p, 제곱합은 %p²; SST=0이면 R2=NA |
| [compare_attitude_models 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L58) | `완전한 attitude형 숫자 표` | 평균/1/2/6변수 모형의 비교 4행 | 같은 행 유지, R2 증가만으로 예측력 판정 불가 |
| [partial_regression 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L72) | `data, target="privileges", controls="complaints"` | points$rx/ry, full, residual_fit, slope | 양쪽을 동일한 controls로 잔차화; 인과효과 아님 |
| [predict_conditions 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L89) | `두 변수 lm, 같은 길이의 complaints/privileges 벡터` | 입력 순서의 rating_hat와 범위 경고 | 0–100 유한 수치, 재적합 없음; 개별 범위 안이어도 공동 지지 보장 안 됨 |
| [candidate_line 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L105) | `x/y 표, intercept=1, slope=1.2` | points, SSE | 후보 평가이며 최소화 실행이 아님 |
| [plot_deviation_story 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L116) | `selected=2, mode="three"/"mean"/"fit"` | 그림; invisibly 편차분해 | 같은 관측점에서 기준 예측만 변경 |
| [plot_conditional_slice 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-tools.R#L135) | `두 변수 lm, privileges=50, data` | 고정 조건 그림; invisibly 예측 표 | 회색 원자료는 privileges가 서로 다름 |

## 바로 실행하는 예

```r
fit <- fit_attitude()
coef(fit)
predict_conditions(fit, c(60,70), c(50,50))
ss_decomposition(fit)$summary
```

예측은 약59.6402,67.4437이며 차이는7.8034%p입니다. 입력 비율의 10%p 차이에 대한 조건부 예측 차이입니다. 측정되지 않은 요인이나 인과성을 통제했다는 뜻은 아닙니다.

공식 함수: [lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), [model.matrix](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/model.matrix.html). R 기본 함수는 이 공식 문서에서 인자와 반환을 확인하세요.
