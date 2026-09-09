# 공통 함수 안내: https://github.com/lunalab-ai/regre/blob/main/src/API.md
# source(path)는 R 정의 파일을 현재 환경에 읽어 들입니다(모델 학습 아님).
# classify_minutes(minutes, threshold=45): 숫자 벡터 -> fast/slow/missing ordered factor.
# threshold 이하는 fast, 초과는 slow, NA/NaN은 missing이며 입력을 변경하지 않습니다.
# summarize_by_shift(data): shift/minutes 열 -> shift/n_observed/mean_minutes 표.
# 평균은 결측 제외, 전부 결측인 집단은 NaN. 작은 예: c(30,50,NA) -> fast,slow,missing.
# 회귀분석의 이해 · 2026-09-09 · w02b
# 위에서부터 한 표현식씩 실행하세요.

data_path <- file.path("data", "w02b-observations.csv")
tools_path <- file.path("..", "..", "..", "src", "r-syntax-tools.R")
observations <- read.csv(data_path, na.strings = "", stringsAsFactors = FALSE)
source(tools_path)

# 1. W02A 회상
observations$minutes
observations[observations$units >= 5, c("id", "units", "minutes")]

# 2. 행렬, 리스트, 요인
design <- cbind(intercept = 1, units = observations$units)
design[1:3, ]
storage.mode(design)

lesson_object <- list(
  data = observations,
  design = design,
  note = "synthetic practice data"
)
names(lesson_object)
lesson_object$data$minutes

observations$shift <- factor(
  observations$shift,
  levels = c("morning", "afternoon", "evening")
)
levels(observations$shift)
table(observations$shift)

# 3. 파일 입출력
getwd()
list.files("data")
head(observations)
str(observations)
output_path <- file.path(tempdir(), "w02b-summary-output.csv")
write.csv(observations, output_path, row.names = FALSE, na = "")
round_trip <- read.csv(output_path, na.strings = "", stringsAsFactors = FALSE)
stopifnot(nrow(round_trip) == nrow(observations))

# 4. 연산자와 조건문
observed <- !is.na(observations$minutes)
needs_review <- is.na(observations$minutes) |
  observations$minutes < 0 |
  observations$minutes > 120
sum(observed)
which(needs_review)

threshold <- 45
one_value <- 52
if (is.na(one_value)) {
  "missing"
} else if (one_value <= threshold) {
  "fast"
} else {
  "slow"
}

# 5. 반복문, 함수, apply 계열
loop_result <- numeric(nrow(observations))
for (i in seq_len(nrow(observations))) {
  loop_result[i] <- observations$units[i] * 10
}
vector_result <- observations$units * 10
stopifnot(identical(loop_result, vector_result))

observations$status <- classify_minutes(observations$minutes, threshold)
table(observations$status)

column_means <- sapply(observations[c("units", "minutes")], mean, na.rm = TRUE)
row_means <- apply(design, 1, mean)
shift_summary <- summarize_by_shift(observations)
column_means
head(row_means)
shift_summary

# 직접 작성 1: threshold를 55로 바꿔 분류 결과를 비교하세요.
# 직접 작성 2: minutes가 40 이상 70 이하인 행을 선택하세요.
# 오류 해결: 아래 코드를 복사해 &를 &&로 바꾸면 왜 경고/오류 또는 다른 결과가 나는지 설명하세요.
# observations$minutes >= 40 & observations$minutes <= 70

stopifnot(
  nrow(observations) == 8,
  sum(is.na(observations$minutes)) == 1,
  identical(loop_result, vector_result),
  sum(observations$status == "fast", na.rm = TRUE) == 4
)
