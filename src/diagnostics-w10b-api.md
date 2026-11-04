# W10B · 함수의 목적·입력·출력과 실제 정의

고정 버전 2026-fall-w10b. 비가중·절편 포함·유한 숫자·가법·완전계수 OLS, 동일 완전행을 사용합니다. 수치 함수에는 네트워크·설치·자동 제외·자료 변경이 없습니다. 부트스트랩의 다운로드/캐시는 별도 준비 기능입니다.

## w10b_deletion_trace

입력: 기존 lm과 원래 정수 행번호1:n. 출력:list(status,predictions,score,coefficients,n,k,df,s,s_deleted,numerator,denominator,Cook_from_predictions). predictions는 원래 n행의 full/deleted/difference/squared_change/cumulative_squared_change이며 차이는 전체−제외 후입니다. 높이는 y단위, 제곱은y단위², 지표는무단위. 제외로 계수 추정이 불가능하면 predictions=NULL과 상태를 반환합니다. 예: 교육용4번 Cook약.413265.

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-w10b.R#L8)

## w10b_effect_trace

입력: 같은 전체 lm과 기존 관심 변수의 정확한 이름문자열. 출력:list(variable,n,k,df,controlled,coefficient,av_slope,data). data는 같은 n행의 원래x/y, 두 보조 예측, AV양쪽 잔차, 전체 예측/잔차, 성분, CPR좌표입니다. 각 원래 단위를 보존합니다. 예:Hills Distance의AV기울기373.072677초/마일.

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-w10b.R#L27)

## w10b_pr_trace

입력: 위 lm과 원래 정수 행번호. 출력:1행 data.frame(row,n,k,e,h,SSE,d_squared,P,R,Hadi). 가로R/세로P이며 R은부호를잃습니다. 지표가 정의되지 않으면 NA를보존하며0으로바꾸지않습니다.

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-w10b.R#L45)

## w10b_huber_trace

입력: 유한 숫자표준화잔차벡터u, 양의스칼라c(기본1.345). 출력:data.frame(u,quadratic_loss,huber_loss,weight). 무단위 가중치는오류확률이아니며 h를입력으로쓰지않습니다. 예:u2의가중치.6725. 실제rlm적합을대신실행하는함수는아닙니다.

[실제 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-w10b.R#L57)

## 재사용하는 기존 정의

- [잔차·지레값과 OLS검증](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics.R)
- [영향력·실제 제외 재적합](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-influence.R)
- [AV·CPR](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-effects.R)

기존API와 과거태그·링크를 유지합니다. factor/interaction/가중모형/rlm에 이 OLS API를 무단 적용하지 않습니다. 일반 R의 lm/residuals/predict는 각 모형의 자료와 단위에서 실행합니다.
