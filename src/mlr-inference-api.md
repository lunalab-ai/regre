# W05B · 공통 함수 읽기

고정 버전 2026-fall-w05b. 기존 API와 이전 태그는 보존합니다. 함수별 정의 줄과 아래 R 주석을 함께 읽으세요.

| 함수 정의 | 입력 → 출력과 조건 |
|---|---|
| [mlr_validate_fit 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L6) | lm → 입력 검증. 비가중·무오프셋·완전 열계수·양의 잔차 자유도를 요구합니다. |
| [mlr_coefficient_table 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L21) | lm, `level=.95`, `null=0` → 계수 순서의 추정값·SE·t·p·CI 표. 정규오차 추론이며 계수 단위를 사용합니다. |
| [mlr_nested_f 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L37) | 축소 lm, 완전 lm → 한 행의 F 표. 동일 반응·동일 행·설계 공간의 내포성을 검사합니다. |
| [mlr_linear_test 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L59) | lm, L(q×k), `r=0` → 제약 검정 F 표. L 열 순서는 coef와 같고 계수 공분산을 포함합니다. |
| [mlr_interval_comparison 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L77) | lm, newdata, `level=.95`, `noise_multiplier=1` → 조건별 CI/PI 두 행. 원래 Y 단위입니다. 배율 변경은 가상 시나리오입니다. |
| [mlr_scaling 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L101) | rating/complaints/learning 숫자 표 → 네 모형·계수 표·원래 단위 예측·학습 변환. 기본 자료는 attitude입니다. |
| [mlr_simulate 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference.R#L130) | `B=1000`, `sigma_error=7`, `seed=730` → 고정 X와 정규오차를 이용한 모의 계수와 요약. 난수 상태를 복원합니다. 실제 추가 관측이 아닙니다. |

함수는 사용자 데이터를 바꾸거나 네트워크에 전송하지 않습니다. `mlr_scaling()`은 네 OLS를 적합하고 `mlr_simulate()`는 모의 자료를 반복 적합합니다. 나머지 계산 함수는 이미 적합한 lm을 읽으며 모델을 다시 학습하지 않습니다. `source()` 자체는 함수 정의를 읽는 작업입니다.

```r
fit <- lm(rating~complaints+learning,data=attitude)
mlr_coefficient_table(fit)
mlr_interval_comparison(fit,data.frame(complaints=66.6,learning=mean(attitude$learning)))
```

평균 조건의 점 예측은 64.63333이고 95%CI 약[62.07969,67.18698],PI 약[50.41525,78.85141]입니다. 한 행은 부서입니다. 단위는 %이고변화량은 %p입니다.

공식기본API: [lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), [scale](https://stat.ethz.ch/R-manual/R-devel/library/base/html/scale.html), [summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html), [anova.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.lm.html), [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), [vcov](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/vcov.html).
