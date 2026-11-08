# W10A: small, inspectable teaching operations. Base R only; no downloads,
# installation, hidden global options, automatic deletion or input mutation.
# API: diagnostics-learning-api.md, frozen with 2026-fall-w10a.

# data.frame with finite numeric x/y, >=4 rows, varying x; one original row and
# finite vertical delta -> list(before, after, trace, data). Fits unweighted
# OLS with an intercept, holding every x fixed. delta affects one y only.
learning_point_shift <- function(data, row, delta=10) {
  if (!is.data.frame(data) || !all(c("x","y") %in% names(data)) ||
      nrow(data)<4L || !is.numeric(data$x) || !is.numeric(data$y) ||
      any(!is.finite(data$x)) || any(!is.finite(data$y)) ||
      length(unique(data$x))<2L) stop("Use >=4 finite numeric x/y rows with varying x.")
  if (length(row)!=1L || !is.numeric(row) || !is.finite(row) ||
      row!=as.integer(row) || row<1L || row>nrow(data))
    stop("row must identify one original observation.")
  if (length(delta)!=1L || !is.numeric(delta) || !is.finite(delta))
    stop("delta must be one finite numeric vertical change.")
  before <- lm(y~x,data=data)
  changed <- data
  changed$y[row] <- changed$y[row]+delta
  after <- lm(y~x,data=changed)
  h <- unname(hatvalues(before)[row])
  trace <- data.frame(row=as.integer(row),h=h,delta_y=delta,
    fitted_before=unname(fitted(before)[row]),fitted_after=unname(fitted(after)[row]),
    residual_before=unname(residuals(before)[row]),residual_after=unname(residuals(after)[row]),
    delta_fitted=unname(fitted(after)[row]-fitted(before)[row]),
    delta_residual=unname(residuals(after)[row]-residuals(before)[row]))
  list(before=before,after=after,trace=trace,data=changed)
}

# Finite numeric vector -> one row per ORDERED value, retaining original row.
# x coordinate qnorm(ppoints(n)), y coordinate sorted value. Probability is an
# intermediate column, NOT the horizontal axis. Mirrors qqnorm(datax=FALSE).
# With ties, original order is retained; no claim of an exact expected score.
learning_qq_table <- function(values) {
  if (!is.numeric(values) || length(values)<2L || any(!is.finite(values)))
    stop("Use at least two finite numeric values.")
  n <- length(values)
  index <- order(values,method="radix")
  probability <- ppoints(n)
  data.frame(rank=seq_len(n),original_row=index,probability=probability,
    normal_quantile=qnorm(probability),ordered_value=unname(values[index]))
}

# Official Salary Survey input: data.frame S (USD/year), X (years), E (1/2/3
# education codes), M (0/1 management), identical complete rows. Returns a NEW
# data.frame retaining original row IDs and adding explicitly coded Education.
# reference is 1/2/3, not a measured amount. Treatment contrasts are explicit,
# so a caller's global contrast options cannot change the parameterization.
salary_prepare <- function(data, reference=3L) {
  columns <- c("S","X","E","M")
  if (!is.data.frame(data) || !all(columns %in% names(data)) || nrow(data)<8L ||
      !all(vapply(data[columns],is.numeric,logical(1))) ||
      any(!is.finite(as.matrix(data[columns]))) ||
      any(!data$E %in% 1:3) || any(!data$M %in% 0:1))
    stop("Use complete finite S/X/E/M data; E=1,2,3 and M=0,1.")
  if (length(reference)!=1L || !is.numeric(reference) || !is.finite(reference) ||
      !reference %in% 1:3) stop("reference must be education code 1, 2 or 3.")
  labels <- c("HighSchool","Bachelor","Graduate")
  d <- data[columns]
  d$row_id <- seq_len(nrow(d))
  d$Education <- factor(labels[d$E],levels=c(labels[reference],labels[-reference]))
  contrasts(d$Education) <- contr.treatment(levels(d$Education),base=1)
  d
}

# Same source rows, optional EXPLICIT sensitivity omission by original row ID.
# Returns an lm with additive S~X+Education+M or S~X+Education*M. The latter is
# category x category interaction: no X:M or X:Education term, hence common
# experience slope. Requires all six groups, rejects rank loss.
# k=fit$rank, NOT raw variable count+1.
salary_fit <- function(data, interaction=FALSE, omit_row=integer(), reference=3L) {
  if (length(interaction)!=1L || !is.logical(interaction) || is.na(interaction))
    stop("interaction must be TRUE or FALSE.")
  d <- salary_prepare(data,reference)
  if (!is.numeric(omit_row) || any(!is.finite(omit_row)) ||
      any(omit_row!=as.integer(omit_row)) || any(!omit_row %in% d$row_id))
    stop("omit_row must contain valid original row IDs, or integer().")
  selected <- d[!d$row_id %in% omit_row,,drop=FALSE]
  groups <- table(selected$Education,factor(selected$M,levels=0:1))
  if (any(groups==0L))
    stop("Keep observations in all six education/management groups for this teaching comparison.")
  formula <- if (interaction) S~X+Education*M else S~X+Education+M
  fit <- lm(formula,data=selected)
  if (fit$rank!=ncol(model.matrix(fit)) || df.residual(fit)<1L)
    stop("Selected rows do not support a full-rank model with residual degrees of freedom.")
  attr(fit,"salary_rows") <- selected$row_id
  attr(fit,"salary_interaction") <- interaction
  fit
}

# Fitted salary lm + one finite experience in years + confidence level -> six
# education/management predictions and CIs for GROUP MEANS, not individual pay.
# Marks extrapolation beyond the overall fitted experience range; comparing
# groups still requires checking each group's observed range and support.
salary_group_predictions <- function(fit, experience=5, level=.95) {
  if (!identical(class(fit),"lm") || is.null(attr(fit,"salary_rows")))
    stop("Use an lm returned by salary_fit.")
  if (length(experience)!=1L || !is.numeric(experience) || !is.finite(experience) ||
      length(level)!=1L || !is.numeric(level) || !is.finite(level) || level<=0 || level>=1)
    stop("Use one finite experience and 0 < level < 1.")
  d <- data.frame(X=experience,
    Education=factor(rep(c("HighSchool","Bachelor","Graduate"),each=2),
                     levels=fit$xlevels$Education),M=rep(0:1,3))
  value <- predict(fit,newdata=d,interval="confidence",level=level)
  observed <- model.frame(fit)$X
  data.frame(d,S_hat=unname(value[,"fit"]),mean_lwr=unname(value[,"lwr"]),
    mean_upr=unname(value[,"upr"]),
    extrapolation=experience<min(observed) || experience>max(observed))
}

# Six predictions -> three management gaps at the SAME experience. Point
# contrasts only; no causal interpretation and no automatic variable choice.
salary_group_gaps <- function(fit, experience=5) {
  z <- salary_group_predictions(fit,experience)
  i <- seq.int(1L,5L,by=2L)
  data.frame(Education=as.character(z$Education[i]),X=experience,
    management_gap=z$S_hat[i+1L]-z$S_hat[i])
}
