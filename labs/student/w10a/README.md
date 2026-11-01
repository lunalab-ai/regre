# W10A · 직접 바꾸고 설명하는 R 실습

회귀진단의 기초부터 범주형 예측변수까지. 설치가 어렵다면 [온라인 R](https://lunalab-ai.github.io/regre/w10a.html)을 사용하세요. R/QMD와 독립 R Colab A/B는 같은 계산을 제공합니다. 준비 셀은 동봉 파일을 먼저 읽고 없을 때 고정 태그2026-fall-w10a에서 필요한 파일만 내려받아 MD5를 확인합니다. 수정 파일을 덮어쓰지 않습니다. 공개 배포 SHA-256 검증은 별도 절차입니다.

함수 `source()`는 정의를 읽고 `lm()`은 모형을 적합합니다. [입력·출력·실제 정의 API](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/src/diagnostics-learning-api.md)를 먼저 확인하세요. toy는 교육용5행, NY는20행·질소 원척도, Hills는35행·초/마일/피트, Salary는46명·연봉 달러/경력 년입니다. 삭제 비교는 원자료를 변경하지 않습니다.

필수 L01–L06과 반복 L07–L12의 조건·빈 기록란은 [워크북](https://github.com/lunalab-ai/regre/blob/2026-fall-w10a/course/notion/w10a/w10a-workbook.md)에 있습니다. 아래 예제의 출력은 설명용 E예제이며 연습 정답을 채워 주는 코드가 아닙니다. 먼저 손으로 계산한 뒤 관심 행·이동량·경력·상호작용을 바꾸어 검산하세요. 질문마다 예상, 손계산, 실행 차이, 한 문장 해석, 추가 확인을 남깁니다.

RStudio에서는 W10A.Rproj를 열고 w10a-diagnostics.R 또는 QMD를 실행하세요. app/app.R은 data폴더와 함께 사용합니다. 온라인 R은 설치 없이, 앱 편집기는 코드까지 바꿀 수 있습니다. 다운로드 코드의 데이터폴더를 함께 보존하세요.
