# W06B teaching helpers. Synthetic demonstration data, unrelated to answer keys.
# All functions are pure: no network, file writes, random state, or input mutation.

# review_data(): no inputs -> data.frame; minutes are minutes, units are counts.
review_data <- function() {
  data.frame(id=sprintf("D%02d",1:8),units=1:8,
             minutes=c(14,24,38,41,NA,63,70,84),
             shift=rep(c("AM","PM"),each=4),stringsAsFactors=FALSE)
}

# review_select(data, shift="all", limit=Inf): select original rows, preserve order.
# Required columns shift and minutes; missing minutes are retained for analysis.
review_select <- function(data,shift="all",limit=Inf) {
  stopifnot(is.data.frame(data),all(c("shift","minutes") %in% names(data)),
            is.numeric(data$minutes),length(shift)==1,shift %in% c("all","AM","PM"),
            is.numeric(limit),length(limit)==1,!is.na(limit))
  keep <- (shift=="all" | (!is.na(data$shift) & data$shift==shift)) &
          (is.na(data$minutes) | data$minutes<=limit)
  data[keep,,drop=FALSE]
}

# review_summary(x, missing="exclude", scale=1): one row, explicit denominator.
# exclude = observed-only; keep = unknown mean when any NA; zero = counterfactual.
# Zero replacement is a comparison assumption, not an automatic recommendation.
# Empty/all-missing observed sets produce NA, not a meaningful zero average.
review_summary <- function(x,missing=c("exclude","keep","zero"),scale=1) {
  missing <- match.arg(missing)
  stopifnot(is.numeric(x),all(is.finite(x)|is.na(x)),
            is.numeric(scale),length(scale)==1,is.finite(scale),scale>0)
  total <- length(x); observed <- sum(!is.na(x)); absent <- sum(is.na(x))
  values <- x*scale
  if(missing=="exclude") values <- values[!is.na(values)]
  if(missing=="zero") values[is.na(values)] <- 0
  denominator <- length(values)
  numerator <- if(denominator==0) NA_real_ else sum(values)
  result <- if(denominator==0) NA_real_ else numerator/denominator
  data.frame(n_total=total,n_observed=observed,n_missing=absent,
             sum_used=numerator,denominator=denominator,mean=result,
             policy=missing,stringsAsFactors=FALSE)
}
