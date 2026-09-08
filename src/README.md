# 회귀분석 수업용 R 공통 함수

`r-syntax-tools.R`에는 여러 차시와 누적 Shiny 앱에서 재사용할 수 있는 기본 R 함수를 둡니다.

```r
source("src/r-syntax-tools.R")
classify_minutes(c(30, 50, NA), threshold = 45)
```

- `classify_minutes()`: 시간 벡터를 fast/slow/missing 순서형 요인으로 분류합니다.
- `summarize_by_shift()`: 근무조별 관측 수와 결측 제외 평균을 계산합니다.

공개 가능한 합성 자료만 사용하며 교수자 실습 정답은 이 폴더에 두지 않습니다.
