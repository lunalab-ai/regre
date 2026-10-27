# W09B · 영향력·변수 효과 API

고정 버전: **2026-fall-w09b**. 기존 `src/diagnostics.R`를 먼저 읽고 영향력·효과 모듈 순서로 `source(..., encoding="UTF-8")`합니다. source는 정의 로딩이고 lm은 적합입니다. 기존 API·과거 태그·학생 주소는 유지합니다.

입력 계약: 절편 포함, 원래의 유한 수치 변수, 가중치·offset 없는 완전열계수 일반 lm. 같은 완전 관측행을 사용합니다. rlm/glm, 변환·상호작용·범주형 예측변수, 누락행, 잔차 자유도≤1, 0에 가까운 전체 오차분산은 이 계약에서 거부합니다. 더 넓은 통계 모형이 잘못되었다는 뜻이 아니라 이번 학습 함수의 명시적 지원 범위입니다.

| 함수 | 입력 → 출력 | 단위·부작용·경계 |
|---|---|---|
| diag_influence | lm → 원래 관측별 표 | raw는 반응 단위, 나머지 진단은 무단위. Cook은 전체 분산, DFFITS는 삭제 분산. Hadi=P+R; P-R x=R,y=P. 원자료 수정·네트워크·자동 삭제 없음 |
| diag_deleted_fit | lm, 원래 행 번호 i → 계수·원래 모든 행의 두 예측·Cook·삭제 s | 실제 동일 설계의 삭제 재적합. 예측과 차이는 반응 단위. 삭제 순위 손실/h=1은 명시적 undefined 상태와 NA |
| diag_added_variable | lm, 정확한 수치 예측변수 이름 → 좌표·기울기·전체 계수 | 같은 다른 변수와 절편을 양쪽에서 제거. x잔차는 관심 변수 단위, y잔차는 반응 단위. 기존 자료 변경 없음 |
| diag_component_residual | lm, 변수 이름 → 원래 x·e·b*x·e+b*x 표 | 원래 x축, 세로는 반응 단위. 실제 반응값과 구별. 인과효과 추정 함수가 아님 |

지원되는 간단한 예:

```r
fit <- lm(y ~ x, data=data.frame(x=0:5,y=c(1,2,2,4,4,5)))
tab <- diag_influence(fit)
tab[4,c("h","Cook","DFFITS","Hadi")]
diag_deleted_fit(fit,4)$Cook
diag_added_variable(fit,"x")$slope
```

이것은 공개 설명 예제이며 연습 답을 조회하는 함수는 없습니다. h=1·삭제 분산 불안정 등의 NA/상태를 읽고 0으로 바꾸지 않습니다. diag_residuals의 기존 수치 안정성 판정을 보존합니다. 실제 교재 적용은 공식 NYRivers20강/Scottish.Hills35경주를 사용합니다. Time 초/Distance 마일/Climb 피트이며 MASS::hills로 조용히 대체하지 않습니다.

## 실제 정의 바로가기
- [diag_validate_ols](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-influence.R#L4)
- [diag_influence](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-influence.R#L21)
- [diag_deleted_fit](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-influence.R#L41)
- [diag_effect_variable](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-effects.R#L4)
- [diag_added_variable](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-effects.R#L14)
- [diag_component_residual](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-effects.R#L29)
