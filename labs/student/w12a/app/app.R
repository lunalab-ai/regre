library(shiny)

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

fit_on_count_scale <- function(d, formula, inverse) {
  fit <- lm(formula, data = d, na.action = na.fail)
  prediction <- inverse(as.numeric(predict(fit, newdata = d)))
  error <- d$N_t - prediction
  rows <- data.frame(t = d$t, observed = d$N_t, fitted_count = prediction,
                     count_error = error, squared_error = error^2,
                     std_residual_fit_scale = as.numeric(rstandard(fit)))
  list(fit = fit, rows = rows, rmse = sqrt(mean(rows$squared_error)))
}

# B2 편집: log(N_t) ~ t로 바꿀 때 inverse도 exp로 바꾸세요.
student_formula <- function() N_t ~ t
student_inverse <- identity

d <- read_bacteria()
raw <- lm(N_t ~ t, d)

ui <- fluidPage(
  titlePanel("W12A | 변수변환으로 두 적합 비교하기"),
  p("편집기에서 student_formula와 student_inverse를 각각 바꾼 뒤 Run을 누르세요."),
  p("같은 관측 15행을 사용합니다. 표·그림·다운로드에서 현재 식의 결과를 확인하세요."),
  verbatimTextOutput("summary"), plotOutput("curve"), plotOutput("residual"),
  tableOutput("trace"), uiOutput("csv_link", inline = TRUE),
  uiOutput("replay_link", inline = TRUE)
)
server <- function(input, output, session) {
  result <- reactive(fit_on_count_scale(d, student_formula(), student_inverse))
  output$summary <- renderPrint({
    r <- result()
    cat("Formula:", deparse(formula(r$fit)),
        "\nCount RMSE:", sprintf("%.6f", r$rmse),
        "\nLast fitted count:", sprintf("%.6f", tail(r$rows$fitted_count, 1)), "\n")
  })
  output$curve <- renderPlot(plot_decay(d, list("Raw count fit" = fitted(raw),
                                                "My edited fit" = result()$rows$fitted_count)))
  output$residual <- renderPlot(plot_decay_residuals(d, result()$fit, "My edited fit"))
  output$trace <- renderTable(result()$rows, digits = 4)
  download_link <- function(id, filename, text, lines, mime) {
    # The table is small. Build a self-contained download that also works in Shinylive.
    payload <- paste(lines, collapse = intToUtf8(10))
    data_url <- paste0("data:", mime, ";charset=utf-8,",
                       utils::URLencode(payload, reserved = TRUE, repeated = TRUE))
    tags$a(text, id = id, href = data_url, download = filename,
           class = "btn btn-default")
  }
  output$csv_link <- renderUI({
    lines <- capture.output(write.csv(result()$rows, row.names = FALSE))
    download_link("csv", "w12a-fit.csv", "현재 결과 CSV", lines, "text/csv")
  })
  output$replay_link <- renderUI({
    code <- c("# W12A current code and observations",
              paste0("d <- ", paste(capture.output(dput(d)), collapse = "\n")),
              paste0("student_formula <- ", paste(deparse(student_formula), collapse = "\n")),
              paste0("student_inverse <- ", paste(deparse(student_inverse), collapse = "\n")),
              paste0("fit_on_count_scale <- ", paste(deparse(fit_on_count_scale), collapse = "\n")),
              "out <- fit_on_count_scale(d, student_formula(), student_inverse)",
              "write.csv(out$rows, 'w12a-replayed.csv', row.names = FALSE)",
              "print(out$rmse)")
    download_link("replay", "w12a-replay.R", "현재 계산 재실행 R", code, "text/plain")
  })
}
shinyApp(ui, server)
