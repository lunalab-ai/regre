# 회귀분석의 이해
# 동덕여자대학교 데이터사이언스전공 유원상 교수
# 2026년 2학기
# 1주차 실습: R/Quarto 환경 점검과 첫 회귀 앱의 씨앗

# 0. 환경 점검 ------------------------------------------------------------
R.version.string
getwd()
Sys.which("quarto")

required_packages <- c("knitr", "rmarkdown", "shiny")
package_status <- data.frame(
  package = required_packages,
  installed = vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
)
package_status

# TODO 1: 모든 패키지가 설치되었는지 all()로 확인하세요.
# all_installed <- all(...)

# 1. R 객체와 데이터프레임 -----------------------------------------------
height <- 1.5
height

units <- c(1, 2, 3, 4, 4, 5)
minutes <- c(23, 29, 49, 64, 74, 87)

repair_preview <- data.frame(Units = units, Minutes = minutes)
class(repair_preview)
dim(repair_preview)
names(repair_preview)
str(repair_preview)

# TODO 2: MinutesPerUnit 열을 추가하세요.
# repair_preview$MinutesPerUnit <- ...

# 2. 데이터 불러오기 ------------------------------------------------------
data_path <- file.path("data", "Computer.Repair.txt")
stopifnot(file.exists(data_path))
repair <- read.table(data_path, header = TRUE)
head(repair, 5)
str(repair)
summary(repair)

# TODO 3: nrow(), ncol(), names()로 데이터 정보를 확인하세요.

# 3. 산점도 ---------------------------------------------------------------
plot(
  Minutes ~ Units,
  data = repair,
  pch = 19,
  xlab = "수리할 부품 수 (Units)",
  ylab = "수리 시간 (Minutes)",
  main = "컴퓨터 수리시간 데이터"
)

# 4. 회귀모형 미리보기 ----------------------------------------------------
preview_model <- lm(Minutes ~ Units, data = repair)
preview_model
coef(preview_model)

repair$Fitted <- fitted(preview_model)
repair$Residual <- residuals(preview_model)
head(repair, 6)

plot(Minutes ~ Units, data = repair, pch = 19)
abline(preview_model, lwd = 2)
segments(repair$Units, repair$Fitted, repair$Units, repair$Minutes, lty = 2)

# TODO 4: 첫 번째 잔차를 관측값 - 적합값으로 직접 계산하세요.

# 5. 예측 -----------------------------------------------------------------
new_jobs <- data.frame(Units = c(7, 11))
predict(preview_model, newdata = new_jobs)

# TODO 5: Units = 12인 데이터프레임을 만들고 예측하세요.

# 6. 앱 실행 --------------------------------------------------------------
# if (interactive()) shiny::runApp("app")

# 7. 디버깅 ---------------------------------------------------------------
# 아래 오류를 각각 수정하세요.
# read.table("ComputerRepair.txt", header = TRUE)
# mean(repair$minutes)
# mean(c("23", "29", "49"))
# predict(preview_model, newdata = data.frame(Unit = 7))
