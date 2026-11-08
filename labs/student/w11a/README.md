# W11A · 식을 읽고 실제 계산을 바꾸는 R 실습

주교재6.1–6.4입니다. Salary46명과 Preemployment20명의 자료·단위를 구별합니다. 예상→손계산→실행→해석을 남기고 마지막에 모형 함수를 실제로 수정합니다. source는 정의를 읽고 lm은 자료로 계수를 적합합니다.

핵심 정의는 src 단일 원본에서 자동 추출한 동일 초기 코드이며 아래에서 직접 실행합니다. 입력 검사 함수는 유한값·완전계수·같은 행·중첩을 확인합니다. 수정한 사본은 이후 계산에 사용되며 원래 파일은 덮어쓰지 않습니다. 재시작 후 준비부터 실행하세요. 새 성적 반영 과제나 제출 기한은 없습니다.

[워크북](https://github.com/lunalab-ai/regre/blob/2026-fall-w11a/course/notion/w11a/w11a-workbook.md) · [온라인 R](https://lunalab-ai.github.io/regre/w11a.html) · [누적 앱 편집기](https://lunalab-ai.github.io/regre/apps/w11a/edit/index.html)

RStudio에서는 W11A.Rproj를 열어 R/QMD를 실행합니다. data 폴더를 함께 보존하세요. 온라인 R과 앱은 설치 없이 직접 편집할 수 있습니다.
