# W08A · 재사용 R 함수 안내

함수명 암기는 평가하지 않습니다. 설명을 읽은 뒤 제공된 호출틀을 사용하세요.
자료는 `datasets::attitude`의 동일한 완전 관측30행입니다. 한 행은 부서입니다.
원래 변수는 긍정 응답 비율(%)이며 값의 변화·회귀 예측의 차이는 퍼센트포인트(%p)로 읽습니다.
이 자료의 p는 설명변수 수, k=p+1은 절편 포함 계수 수, q는 검정 제약 수입니다.

W08A 노트북은 새 수업 태그에, 아래 재사용 함수 정의와 다운로드는 실제 검증한 기존 공개 커밋에 고정합니다.
모든 함수는 입력자료를 직접 변경하지 않으며 함수 호출 자체는 네트워크 다운로드·설치를 하지 않습니다.
기본 R의 `lm`, `predict`, `sum`, `sqrt`는 호출 예를 제공하며 내부 구현을 외울 필요가 없습니다.

## `mlr_coefficient_table`

입력: 완전계수 lm, level, 귀무값. 출력: 계수·SE·t·p·계수 CI 표. 평균반응/개별 구간과 다릅니다.

[고정 소스 정의 · L21](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-inference.R#L21)

## `mlr_nested_f`

입력: 같은 반응·행 순서·중첩 관계의 축소/완전 lm. 출력: q·완전모형 df·SSE·F·p. 비중첩 A/B 비교는 거부합니다.

[고정 소스 정의 · L37](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-inference.R#L37)

## `mlr_linear_test`

입력: lm, 제약행렬 L, 우변 r. 출력: q·잔차df·F·p. 동일성 L=(0,1,-1), 합 L=(0,1,1)을 구별합니다.

[고정 소스 정의 · L59](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-inference.R#L59)

## `mlr_interval_comparison`

입력: lm, 이름을 맞춘 newdata, level. 출력: confidence/prediction 각 행의 fit·끝점·width·h0. 기존 모형을 다시 적합하지 않습니다.

[고정 소스 정의 · L77](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-inference.R#L77)

## `mlr_scaling`

입력: rating/complaints/learning을 가진 표. 출력: 원래/X중심화/X·Y표준화/X·Y단위길이 모형·변환기준·원단위 복원 예측. 상수열은 거부합니다.

[고정 소스 정의 · L101](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-inference.R#L101)

## `mlr_simulate`

입력: 반복수B·오차SD·seed. 출력: 고정 X의 합성 반복계수와 이론 SD. 실제 부서를 새로 조사한 자료가 아니며 호출 전 RNG 상태를 복원합니다.

[고정 소스 정의 · L130](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-inference.R#L130)

## `ss_decomposition`

입력: 절편 포함 OLS 모형. 출력: 같은 자료의 편차·제곱합·자유도·R². 이번 주된 분석 모형은 B입니다.

[고정 소스 정의 · L37](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-tools.R#L37)

## `partial_regression`

입력: attitude 표·target·controls. 출력: 통제변수를 제거한 잔차와 편회귀 기울기. 회귀계수의 조건부 해석을 돕습니다.

[고정 소스 정의 · L72](https://github.com/lunalab-ai/regre/blob/ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541/src/mlr-tools.R#L72)

## 작은 호출 예

```r
fit_B <- lm(rating ~ complaints + learning, data=datasets::attitude)
new_B <- data.frame(complaints=66.6, learning=56.3666666667)
mlr_interval_comparison(fit_B, new_B, level=0.95)
```

예측 표는 같은 중심의 두 행을 반환합니다. `confidence`는 같은 조건의 평균, `prediction`은 새 부서 한 곳입니다.
작은 손계산 연습의 수치는 이 실제30부서 설명 예제와 구별합니다.
