# W07B 함수 정의와 입력·출력

기본R만 사용하며 다운로드·자료 수정 없이 계산합니다. 고정 배포 태그의 실제 함수 선언행으로 연결합니다.

## review_fit_data

인수 없음 → 가상 작업 수·시간5행. 문항 정답표 아님.

[review_fit_data · L2](https://github.com/lunalab-ai/regre/blob/2026-fall-w07b/src/review-fit.R#L2)

## review_fit_components

유한한 x,y 쌍3개 이상과 mode → lm모형, 행별 세 편차, 제곱합·교차항·자유도·두 기준의 R². mode는 intercept/origin/mean. X의 모형 행렬이 완전계수여야 함. SST가0이면 중심화R²는NA.

[review_fit_components · L5](https://github.com/lunalab-ai/regre/blob/2026-fall-w07b/src/review-fit.R#L5)

## review_fit_intervals

x,y,x0,level → 점예측·평균신뢰구간·개별예측구간·외삽 표시. 절편 있는 단순회귀, 양의 잔차분산,0<level<1 필요. 통계적 가정은 사용자가 확인.

[review_fit_intervals · L21](https://github.com/lunalab-ai/regre/blob/2026-fall-w07b/src/review-fit.R#L21)

