# W10A · 입력·출력과 실제 함수 정의

고정 버전2026-fall-w10a. source()는 정의를 읽고 함수를 호출해야 계산됩니다. 이 모듈은 base R을 사용하며 네트워크·설치·자동 삭제·입력 자료 변경을 수행하지 않습니다. 모든 예는 학습용 선형 연관이며 인과 효과가 아닙니다.

## learning_point_shift

입력: 숫자 x/y를 갖는 완전한 data.frame(4행 이상, x변화), 원래 row 하나, 유한 delta. 출력: before/after lm, 바뀐 자료 사본 data, trace 표. trace의 h는 무단위, delta_y/delta_fitted/delta_residual은 y단위. 모든 x를 고정하고 한 y만 이동한 실제 재적합. 예: toy3번+10 → 자기 예측+2/잔차+8. 원본은 유지합니다.

[실제 정의 learning_point_shift](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning.R#L8)

## learning_qq_table

입력: 유한 숫자 벡터2개 이상. 출력: 정렬순위rank, 원행original_row, ppoints확률probability, qnorm분위수normal_quantile, 정렬값ordered_value 표. Q-Q의 x는normal_quantile, y는ordered_value. 동률은 원순서를 유지하며 확률열 자체가 x가 아닙니다.

[실제 정의 learning_qq_table](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning.R#L35)

## salary_prepare

입력: 완전한 숫자 S/X/E/M의8행 이상 자료와 reference1/2/3. 출력: 원자료 사본과 row_id, 명시적 treatment coding Education factor. S달러/년, X년, E코드1/2/3,M0/1. 원자료의 E숫자를 양적 예측변수로 사용하지 않습니다.

[실제 정의 salary_prepare](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning.R#L50)

## salary_fit

입력: 위 공식 자료, 논리 interaction, 원행 번호 omit_row, reference. 출력: full-rank lm과 salary_rows/salary_interaction 속성. 기본46행 그대로; omit_row=33은 별도45행 민감도. 상호작용은 Education*M이고 X기울기는 공통입니다. 여섯 집단 관측 유지·양의 잔차자유도를 요구합니다.

[실제 정의 salary_fit](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning.R#L72)

## salary_group_predictions

입력: salary_fit 결과, 유한 experience년, 0~1의 level. 출력: 여섯 Education/M 집단의 X,S_hat,mean_lwr/mean_upr,extrapolation. 구간은 집단 평균 신뢰구간이며 개인 예측구간이 아닙니다. extrapolation은 전체 관측X범위 기준이므로 집단별 자료 지지도 별도로 확인하세요.

[실제 정의 salary_group_predictions](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning.R#L96)

## salary_group_gaps

입력: salary_fit 결과와 experience년. 출력: 학력별 management_gap(관리직−비관리직) 달러/년 표. 같은 경력 조건의 적합 평균 차이이며 인과적 관리직 효과나 격차의 신뢰구간을 자동 제공하지 않습니다.

[실제 정의 salary_group_gaps](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning.R#L114)

## 이전 진단 모듈

[영향력·삭제 진단 API](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-influence-api.md), [변수 효과 API](https://github.com/lunalab-ai/regre/blob/2026-fall-w09b/src/diagnostics-effects-api.md). 비가중·절편 포함·유한 숫자 가법 OLS 전용 경계를 유지합니다. factor/interaction에는 base R의 모형행렬과 전용 Salary함수를 사용하세요. h=1·삭제rank상실·분산0은 0으로 대체하지 않습니다.
