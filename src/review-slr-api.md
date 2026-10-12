# W07A 공통 R 함수 · 입력·출력·정의

기본 R만 사용합니다. source는 정의를 읽고, 함수 호출 시 계산을 수행합니다. 설명용 가상 데이터이며 문항 정답표를 포함하지 않습니다.

## review_slr_data

인수 없음 → 작업 수·시간5행. 설명 예제 생성.

[실제 함수 정의 L5](https://github.com/lunalab-ai/regre/blob/2026-fall-w07a/src/review-slr.R#L5)

## review_slr

x,y,level,null → 편차합·OLS계수·잔차·s·SE·t·계수CI 목록. 유한한 쌍3개 이상과 X변동 필요. 고전적 t추론의 가정은 별도 확인. 완전적합/수치상0에 가까운SE는 추론을NA로 명시.

[실제 함수 정의 L12](https://github.com/lunalab-ai/regre/blob/2026-fall-w07a/src/review-slr.R#L12)

## review_line

x,y,intercept,slope → 후보 직선의 행별 적합값·세로잔차·제곱. OLS를 다시 추정하는 함수가 아님.

[실제 함수 정의 L39](https://github.com/lunalab-ai/regre/blob/2026-fall-w07a/src/review-slr.R#L39)

```r
d <- review_slr_data()
z <- review_slr(d$x,d$y,level=.95,null=0)
z$b1
review_line(d$x,d$y,intercept=1.6,slope=2.2)
```
