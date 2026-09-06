# 누락된 필수 패키지만 설치합니다.
required <- c("knitr", "rmarkdown", "shiny")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) == 0) {
  message("필수 패키지가 모두 설치되어 있습니다.")
} else {
  message("설치할 패키지: ", paste(missing, collapse = ", "))
  install.packages(missing)
}
