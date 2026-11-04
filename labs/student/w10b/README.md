# W10B · 한 점씩 계산하고 설명하는 R 실습

회귀분석의 이해 · 2026-11-04 · 주교재 §5.8–5.15. 이번에는 B·C를 보강하며 §6.1–6.3은 제외합니다. 성적 반영 과제나 제출 기한을 새로 정하지 않습니다.

**예상과 이유 → 손계산 → 실행 → 그림 비교 → 한 문장 해석**을 남깁니다. 설명 예제와 다른 관측을 쓰는 연습을 구별하세요. TODO는 뒤의 설명 예제를 막지 않습니다. 새로 시작하면 준비 셀부터 실행합니다.

[온라인 R](https://lunalab-ai.github.io/regre/w10b.html) · [누적 앱 편집기](https://lunalab-ai.github.io/regre/apps/w10b/edit/index.html) · [입출력과 실제 함수 정의](https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-w10b-api.md)

`source()`는 정의를 읽고 `lm()`은 계수를 적합합니다. `w10b_deletion_trace(lm,원래행번호)`는 원래 모든 위치의 두 예측표와 지표를 반환합니다. `w10b_effect_trace(lm,"Distance")`는 같은 행의 두 보조회귀 잔차·원래 x·CPR좌표를 반환합니다. 함수가 자료를 자동 삭제하지 않습니다.

자료는 교육용5행(x/y교육용단위), NY20행(Nitrogen원척도/ComIndl%), Hills35행(Time초/Distance마일/Climb고도상승피트)입니다. 준비 코드는 동봉 자료→지정 캐시→고정태그 다운로드 순으로 필요한7파일을 확인하고 MD5를 대조합니다. 편집 파일을 덮어쓰거나 실패를 가짜 자료로 대체하지 않습니다. 공개 ZIP/Release의 SHA-256 검증과 구별합니다.

RStudio에서는 W10B.Rproj를 열고 R/QMD를 실행합니다. app/app.R을 실행할 때 data폴더를 함께 보존하세요. 브라우저 R과 앱 편집기는 설치 없이 사용할 수 있습니다. 재시작 후에는 준비부터 실행합니다.
