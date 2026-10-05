# W06A · 함수 정의 바로가기

고정 버전 2026-fall-w06a. R파일의 함수 선언줄을 바로 엽니다. 아래 조건과 단위를 확인한 뒤 사용하세요.

| 함수 | 입력 → 출력 / 조건 |
|---|---|
| [diag_validate_fit 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics.R#L3) | lm→검증. 비가중·무오프셋·완전열계수,ν>1,양의잔차분산. |
| [diag_residuals 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics.R#L16) | lm→관측별 표. raw는Y차이 단위, internal/external 무단위. h=1은NA와이유. 재적합/삭제하지 않음. |
| [diag_hamilton 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics.R#L36) | 동봉CSV 경로→15×3숫자표(Y/X1/X2). 다운로드하지 않음. |
| [diag_hamilton_fits 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics.R#L45) | Hamilton표→동일Y와행의 세모형 R²/SSE/rank. 세 OLS를 적합함. |
| [diag_project 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics.R#L53) | Hamilton표,azimuth=35,elevation=20(도)→row/u/v/depth. 각 열 표준화 후 직교투영. 원자료 변경 없음. |
| [diag_patterns 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics.R#L68) | n=100,seed=605→band/curve/fan/order 네 모의표. 실제 자료 아님. 난수상태 복원. |

```r
source("src/diagnostics.R")
fit <- lm(rating~complaints+learning,data=attitude)
diag_residuals(fit)[1,]
```

내적 잔차 첫 값≈−1.2348835, 외적≈−1.2475416. 정의를 읽은 뒤 R의 [rstandard/rstudent 공식 문서](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/influence.measures.html)와 비교하세요. R `rstandard`는 교재 내적 표준화잔차입니다. `rstudent`의 분자는 원래잔차이며 삭제예측잔차가 아닙니다.

함수는 사용자 자료를 외부로 보내지 않으며 전역 옵션을 바꾸지 않습니다. `diag_patterns`는 모의자료를 만들고 적합하며 RNG상태를 복원합니다. Colab 준비 셀만 고정된 공개 소스/CSV를 최초 다운로드합니다.
