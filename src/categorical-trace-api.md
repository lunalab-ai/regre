# 범주형 OLS · 입력·중간값·출력

고정 버전 2026-fall-w11a입니다. 유한한 완전행·비가중·절편 포함·완전계수 OLS를 사용합니다. 네트워크·설치·자동 관측 삭제는 없습니다. 실제 정의는 실습 본문에서 기본으로 펼쳐 실행합니다.

## salary_prepare

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/diagnostics-learning.R#L50) · 본문 코드와 같은 초기 정의입니다.

## cat_row_trace

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L21) · 본문 코드와 같은 초기 정의입니다.

## salary_fit

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/diagnostics-learning.R#L72) · 본문 코드와 같은 초기 정의입니다.

## cat_fit_trace

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L40) · 본문 코드와 같은 초기 정의입니다.

## cat_two_group_models

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L57) · 본문 코드와 같은 초기 정의입니다.

## cat_group_lines

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L110) · 본문 코드와 같은 초기 정의입니다.

## cat_gap

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L122) · 본문 코드와 같은 초기 정의입니다.

## cat_nested_trace

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L91) · 본문 코드와 같은 초기 정의입니다.

## cat_check_fit

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L5) · 본문 코드와 같은 초기 정의입니다.

## cat_check_pair

[고정된 실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/src/categorical-trace.R#L73) · 본문 코드와 같은 초기 정의입니다.

cat_row_trace는 항별 value/coefficient/contribution, cat_fit_trace는 QR계수와 행별 observed/fitted/residual/squared/cumulative, cat_nested_trace는 같은행 중첩 비교의 SSE/q/df/F/p를 반환합니다. cat_group_lines는 두 집단의 절편·기울기, cat_gap은 gamma+delta*x를 반환합니다. MI와MS 사이의 직접 부분F는 거절합니다.
