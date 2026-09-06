# 회귀분석의 이해 — 1주차 학생용 실습

## 시작

1. 이 ZIP을 완전히 풉니다.
2. `week01_regression.Rproj`를 엽니다.
3. `scripts/check_environment.R`를 실행합니다.
4. 필요하면 `scripts/install_packages.R`를 실행합니다.
5. `week01_lab_student.qmd`를 열고 Render를 누릅니다.
6. 마지막에 `shiny::runApp("app")`을 실행합니다.

## 구조

```text
week01_regression.Rproj
_quarto.yml
week01_lab_student.qmd
week01_lab_student.R
data/Computer.Repair.txt
app/app.R
app/debug_app.R
scripts/check_environment.R
scripts/install_packages.R
scripts/run_app.R
```

## 중요

- ZIP 안에서 직접 실행하지 마세요.
- `setwd()` 대신 `.Rproj`와 상대경로를 사용합니다.
- 학생용 노트북의 빈칸 코드 청크는 기본적으로 렌더링 시 실행되지 않습니다. 직접 완성한 뒤 실행하세요.
- `lm()`은 이번 시간에 전체 흐름을 보여주는 미리보기입니다. 계수의 추정과 해석은 이후 수업에서 배웁니다.
