# W08A 데이터와 공통 코드

이번 복습의 주 자료는 R datasets의 attitude(같은 30개 부서)입니다. 원래 값은 긍정 응답 비율(%), 변화·구간 폭은 퍼센트포인트(%p)로 읽습니다. 작은 손계산 문항의 합성 숫자는 이 실제자료와 구별합니다.

mlr-inference.R와 mlr-tools.R는 이미 공개된 고정 커밋 ba38f5fe7e1c75ac78eac6ff5c33b962c63c8541의 정의를 그대로 재사용합니다. 나머지 파일은 기존 누적 앱의 탭·자료를 보존하기 위한 것입니다. R/QMD를 다운로드하면 이 data 폴더를 함께 보관하세요.

## 기존 자료의 출처 기록

# W06A 데이터와 공통 코드

Hamilton: 주교재 표5.1의 15개 설명용 구성 관측. 원본은 저자 제공 https://www1.aucegypt.edu/faculty/hadi/RABE6/Data6/Hamilton.Data.txt 입니다. 원본 숫자를 변경하지 않고 CSV로 정리했습니다. 네 번째 X2는6.64입니다. 실제 설문 자료가 아닙니다.

attitude: R datasets의30개 부서 설문 집계. 각 열은 긍정 응답 비율(%); 행 순서는 시간 순서로 해석하지 않습니다. Anscombe: R datasets의 설명용 구성 자료.

diagnostics.R은 W06A 공통 정의입니다. 이전 차시 코드/데이터는 누적 앱 호환을 위해 함께 보관합니다. 파일을 R/QMD와 함께 유지하세요.
