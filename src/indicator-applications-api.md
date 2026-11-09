# 지시변수 응용 · 실제 정의와 입력/출력

버전 2026-fall-w11b · base R · 자동 행 삭제나 네트워크 부작용 없음. 원자료 단위를 유지합니다.

## ia_mean_parts

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/indicator-applications.R#L18) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## cat_fit_trace

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/categorical-trace.R#L40) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## cat_nested_trace

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/categorical-trace.R#L91) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## ia_rows

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/indicator-applications.R#L5) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## ia_quarter_prepare

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/indicator-applications.R#L38) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## ia_year_prepare

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/indicator-applications.R#L55) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## ia_full_formula

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/indicator-applications.R#L71) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## ia_year_models

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/indicator-applications.R#L77) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## cat_check_fit

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/categorical-trace.R#L5) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## cat_check_pair

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/categorical-trace.R#L73) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

## cat_row_trace

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11b/src/categorical-trace.R#L21) · 실습 본문에서 같은 정의를 펼쳐 실행합니다.

ia_rows는 완전행/고유source_row를 확인합니다. ia_mean_parts(y,group)는 행별 평균·잔차²와 SST/SSB/SSE/q/df/F/p를 반환합니다. ia_quarter_prepare(data,reference=4)는 Date의 실제 분기와 기준 factor를, ia_year_prepare(data,reference=1975)는 주×연도의 고유키와 기준 factor를 만듭니다. ia_year_models(data,formula_fn)는 common/intercept/full lm 세 개를 반환하며 실제 전달된 함수를 호출합니다. cat_fit_trace/cat_nested_trace의 계약은 기존 categorical-trace API를 유지합니다.
