# 회귀분석의 이해 · 2026-09-07 · w02a
# 강의노트 순서대로 한 표현식씩 실행하세요.
# 추가 데이터·패키지 불필요. 데이터는 설명용 합성 자료입니다.

R.version.string


2 + 3
10 / 4
sqrt(16)


units <- 3
minutes_per_unit <- 5
total_minutes <- units * minutes_per_unit
total_minutes
print(total_minutes)


score <- 80
student_name <- "Kim"
passed <- score >= 60
class(score)
class(student_name)
class(passed)
as.numeric("80") + 5


score == 80
score > 80
measurements <- c(10, NA, 30)
mean(measurements)
is.na(measurements)
mean(measurements, na.rm = TRUE)


mixed <- c(10, "20", 30)
class(mixed)
mixed


minutes <- c(20, 30, 35, 45, 50, 60)
length(minutes)
minutes[1]
minutes[c(1, 3)]
minutes[2:4]
mean(minutes)
sum(minutes)


minutes >= 40
minutes[minutes >= 40]
minutes + 5
minutes


demo <- data.frame(
  units = 1:6,
  minutes = c(20, 30, 35, 45, 50, 60)
)
demo
nrow(demo)
ncol(demo)
names(demo)
str(demo)


demo$minutes
demo[1, 2]
demo[demo$minutes >= 40, ]
mean(demo$minutes)
summary(demo)


plot(demo$units, demo$minutes,
     xlab = "Units", ylab = "Minutes",
     main = "Synthetic practice data", pch = 19)


# 직접 수정 과제: 두 번째·다섯 번째 시간, 35 이하 시간, 초 단위 새 벡터
# 여기에 자신의 코드를 작성하세요.
