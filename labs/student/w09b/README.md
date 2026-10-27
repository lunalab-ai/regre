# W09B · 회귀진단 실습

한 경로를 선택합니다. [온라인 R](https://lunalab-ai.github.io/regre/w09b.html), 동봉 R/QMD/RStudio 프로젝트, 고정 태그의 독립 R Colab A/B를 사용할 수 있습니다. QMD/R은 같은 예제와 12개 연습을 담고 Colab A/B는 주제별로 나눈 대체 경로입니다.

RStudio에서는 W09B.Rproj를 열고 R/QMD를 실행합니다. `data`를 함께 보관하세요. MASS는 R의 권장 패키지이며 Shiny 앱을 데스크톱에서 사용할 경우 shiny 패키지가 필요합니다. 설치가 필요하면 CRAN의 해당 패키지를 설치한 뒤 다시 시작합니다. 개인 파일 업로드나 API 키는 필요 없습니다.

앱은 `shiny::runApp("app")`로 실행합니다. 온라인에서는 Shiny 편집기를 사용합니다. 입력–함수–출력 중 한 연결을 직접 수정하고 CSV/R 코드를 다운로드하세요. 기본 예제는 주석 TODO를 남겨도 끝까지 실행됩니다. 준비 셀은 파일 동일성을 확인하며 수정된 파일을 조용히 덮어쓰지 않습니다.

공통 자산 버전: 2026-fall-w09b. base 파일은 기존 src/diagnostics.R의 동일 내용을 휴대용으로 동봉한 것입니다. 두 신규 모듈의 원본은 src/diagnostics-influence.R와 src/diagnostics-effects.R입니다. 함수 정의와 단위는 고정 버전 API 문서를 확인합니다.

공식 데이터 NYRivers 20강, Scottish.Hills 35경주를 사용합니다. 경주 시간은 초, 거리는 마일, 상승량은 피트입니다. hand-six는 추가 구성한 교육용 자료입니다. NY 단순모형과 네 변수 모형을 구별하세요. 기존 누적 앱 기능은 유지합니다.
