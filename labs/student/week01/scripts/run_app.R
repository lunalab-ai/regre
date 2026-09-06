# RStudio 프로젝트 루트에서 실행하세요.
if (!requireNamespace("shiny", quietly = TRUE)) {
  stop("shiny 패키지가 필요합니다. scripts/install_packages.R를 먼저 실행하세요.")
}
shiny::runApp("app")
