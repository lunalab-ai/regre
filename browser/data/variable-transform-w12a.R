# Data columns: t is the observation index, N_t is in hundreds.
read_bacteria <- function() {
  file_name <- "bacteria-w12a.csv"
  locations <- file.path(c(".", "data", "../data", "labs/student/w12a/data",
                           "../../labs/student/w12a/data", "../../../labs/student/w12a/data"),
                         file_name)
  local <- locations[file.exists(locations)][1L]
  url <- paste0("https://raw.githubusercontent.com/lunalab-ai/regre/2026-fall-w12a/",
                "labs/student/w12a/data/", file_name)
  d <- read.csv(if (is.na(local)) url else local)
  stopifnot(identical(d$t, 1:15), all(is.finite(d$N_t)), all(d$N_t > 0))
  d
}

plot_decay <- function(d, curves, limit = range(c(d$N_t, unlist(curves)))) {
  plot(d$t, d$N_t, pch = 19, col = "#24374D", ylim = limit,
       xlab = "Observation step (6 min)", ylab = "Count (hundreds)")
  abline(h = 0, lty = 3, col = "#7992A3")
  colors <- c("#B64932", "#087D77")
  for (i in seq_along(curves)) {
    lines(d$t, curves[[i]], col = colors[i], lwd = 3, lty = i)
  }
  legend("topright", names(curves), col = colors[seq_along(curves)],
         lwd = 3, lty = seq_along(curves), bty = "n")
}

plot_decay_residuals <- function(d, fit, title) {
  residual <- rstandard(fit)
  plot(d$t, residual, pch = 19, col = "#185A76",
       xlab = "Observation step (6 min)", ylab = "Standardized residual",
       main = title, ylim = c(-3.5, 3.5))
  abline(h = 0, lty = 2, col = "#8B4961")
  text(d$t[c(1, 15)], residual[c(1, 15)], d$t[c(1, 15)], pos = 3, cex = .8)
}
