# Reusable base-R helpers for the regression course.

#' 관측 시간을 임계값으로 분류한다. 학습 모형이 아니라 고정 규칙 함수다.
#' 입력 minutes는 숫자 벡터이며 순서와 길이를 보존한다. threshold는 기본45인
#' 유한한 숫자 하나다. minutes <= threshold는 fast, 더 크면 slow,
#' NA/NaN은 문자 missing 수준으로 분류한다. missing은 결과의 NA가 아니다.
#' 반환은 fast < slow < missing 순서의 ordered factor다. 원본은 변경하지 않는다.
#' 예: as.character(classify_minutes(c(30,50,NA),45))는 fast/slow/missing.
#' 잘못된 입력은 stopifnot 오류다. Inf 시간은 slow, -Inf 시간은 fast가 되므로
#' 실제 관측의 유한성 검사는 분석자가 별도로 수행한다.
#'
#' @param minutes Numeric vector. Missing values are retained as "missing".
#' @param threshold Single finite numeric cutoff.
#' @return An ordered factor with levels fast, slow, missing.
classify_minutes <- function(minutes, threshold = 45) {
  stopifnot(is.numeric(minutes), length(threshold) == 1L,
            is.finite(threshold))
  label <- ifelse(
    is.na(minutes), "missing",
    ifelse(minutes <= threshold, "fast", "slow")
  )
  factor(label, levels = c("fast", "slow", "missing"), ordered = TRUE)
}

#' data의 shift별 관측 개수와 평균 시간을 새 표로 반환한다.
#' data는 shift/ minutes 열을 가진 data.frame이며 minutes는 숫자로 사용한다.
#' split은 shift가 결측인 행과 관측 없는 수준을 제외한다. n_observed는 minutes의
#' 결측을 제외한 개수이고 mean_minutes는 mean(...,na.rm=TRUE)다.
#' 집단의 minutes가 전부 결측이면 n_observed=0, mean_minutes=NaN이다.
#' 출력 열은 shift/n_observed/mean_minutes. 입력 표를 변경하지 않는다.
#' 예: summarize_by_shift(data.frame(shift=c("AM","AM"),minutes=c(30,50)))
#' 는 AM,2,40을 반환한다. 추가 열은 사용하지 않는다.
#'
#' @param data Data frame containing shift and minutes columns.
#' @return Data frame with group, number observed, and mean minutes.
summarize_by_shift <- function(data) {
  stopifnot(is.data.frame(data), all(c("shift", "minutes") %in% names(data)))
  groups <- split(data$minutes, data$shift, drop = TRUE)
  data.frame(
    shift = names(groups),
    n_observed = vapply(groups, function(x) sum(!is.na(x)), integer(1)),
    mean_minutes = vapply(groups, function(x) mean(x, na.rm = TRUE), numeric(1)),
    row.names = NULL
  )
}

# Example:
# classify_minutes(c(30, 50, NA), threshold = 45)
