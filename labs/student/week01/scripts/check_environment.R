# 1주차 실습 환경 점검
cat("R 버전:", R.version.string, "\n")
cat("플랫폼:", R.version$platform, "\n")
cat("작업 폴더:", getwd(), "\n")
cat("Quarto 경로:", Sys.which("quarto"), "\n")

required <- c("knitr", "rmarkdown", "shiny")
status <- data.frame(
  package = required,
  installed = vapply(required, requireNamespace, logical(1), quietly = TRUE)
)
print(status)

cat("데이터 파일 존재:", file.exists(file.path("data", "Computer.Repair.txt")), "\n")
cat("프로젝트 파일 존재:", file.exists("week01_regression.Rproj"), "\n")

if (Sys.which("quarto") == "") {
  message("[확인 필요] Quarto 명령을 찾지 못했습니다.")
}
if (!all(status$installed)) {
  message("[확인 필요] 누락된 패키지: ", paste(status$package[!status$installed], collapse = ", "))
}
