# W06B 기초 복습 함수 안내

고정 버전 2026-fall-w06b · 모든 함수는 입력을 바꾸지 않으며 네트워크·학습·파일 쓰기를 수행하지 않습니다.

## [review_data 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06b/src/review-foundations.R#L5)

인수 없음 → 8행 가상 작업 표. units는 개수, minutes는 분, shift는 AM/PM. 실제 연구 자료가 아닙니다.

## [review_select 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06b/src/review-foundations.R#L13)

data, shift="all", limit=Inf → 조건을 만족하는 행. 결측 시간은 상한 비교가 불가능하여 따로 남깁니다. 원래 순서를 유지합니다.

## [review_summary 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06b/src/review-foundations.R#L26)

숫자 벡터 x, missing="exclude", scale=1 → 전체/관측/결측 건수, 합, 분모, 평균 한 행. exclude는 관측값, keep은 결측 전파, zero는0 가정 비교입니다. 빈집합 평균은NA. scale=60은 분에서 초 변환입니다.

```r
d <- review_data()
review_summary(d$minutes)
review_summary(d$minutes,scale=60)
```

`source()`는 이 정의를 읽습니다. 데이터 다운로드와 체크섬 확인은 노트북 준비 셀에서 따로 수행합니다. 기본 함수: [mean](https://stat.ethz.ch/R-manual/R-devel/library/base/html/mean.html), [추출 연산자](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Extract.html).
