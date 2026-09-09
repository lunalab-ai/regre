# 공통 함수 안내: https://github.com/lunalab-ai/regre/blob/main/src/API.md
# source(path)는 R 정의 파일을 현재 환경에 읽어 들입니다(모델 학습 아님).
# classify_minutes(minutes, threshold=45): 숫자 벡터 -> fast/slow/missing ordered factor.
# threshold 이하는 fast, 초과는 slow, NA/NaN은 missing이며 입력을 변경하지 않습니다.
# summarize_by_shift(data): shift/minutes 열 -> shift/n_observed/mean_minutes 표.
# 평균은 결측 제외, 전부 결측인 집단은 NaN. 작은 예: c(30,50,NA) -> fast,slow,missing.
library(shiny)

# 공개 공통 함수: 로컬 저장소와 브라우저 export 위치를 모두 지원합니다.
tools_path <- file.path("..", "..", "..", "..", "src", "r-syntax-tools.R")
if (!file.exists(tools_path)) tools_path <- file.path("data", "r-syntax-tools.R")
source(tools_path)

repair_path <- file.path("..", "..", "week01", "data", "Computer.Repair.txt")
if (!file.exists(repair_path)) repair_path <- file.path("data", "Computer.Repair.txt")
practice_path <- file.path("..", "data", "w02b-observations.csv")
if (!file.exists(practice_path)) practice_path <- file.path("data", "w02b-observations.csv")

repair <- read.table(repair_path, header = TRUE)
practice <- read.csv(practice_path, na.strings = "", stringsAsFactors = FALSE)
model <- lm(Minutes ~ Units, data = repair)

ui <- fluidPage(
  tags$head(tags$style(HTML("@media (max-width: 700px) {.col-sm-4,.col-sm-8{width:100%;} body{font-size:16px;}}"))),
  titlePanel("회귀분석 누적 실험실"),
  tabsetPanel(
    tabPanel(
      "첫 회귀 예측",
      sidebarLayout(
        sidebarPanel(
          sliderInput("units", "수리할 부품 수", min = 1, max = 15, value = 7, step = 1),
          helpText("1주차 기능을 그대로 유지합니다.")
        ),
        mainPanel(
          h3(textOutput("prediction")),
          plotOutput("regression_plot", height = "420px"),
          verbatimTextOutput("coefficients")
        )
      )
    ),
    tabPanel(
      "R 문법 실험실",
      sidebarLayout(
        sidebarPanel(
          numericInput("threshold", "빠름/느림 기준(분)", value = 45, min = 30, max = 70, step = 5),
          selectInput("shift", "근무조", choices = c("all", sort(unique(practice$shift)))),
          helpText("입력 → 함수 → 표와 그림의 연결을 확인하세요.")
        ),
        mainPanel(
          h3(textOutput("syntax_summary")),
          tableOutput("syntax_table"),
          plotOutput("syntax_plot", height = "380px")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  predicted_minutes <- reactive({
    as.numeric(predict(model, newdata = data.frame(Units = input$units)))
  })
  output$prediction <- renderText(sprintf("예상 수리시간: %.1f분", predicted_minutes()))
  output$coefficients <- renderPrint(coef(model))
  output$regression_plot <- renderPlot({
    plot(Minutes ~ Units, data = repair, pch = 19,
         xlab = "수리할 부품 수 (Units)", ylab = "수리 시간 (Minutes)",
         main = "관측값, 회귀직선과 현재 예측")
    abline(model, lwd = 2)
    points(input$units, predicted_minutes(), pch = 19, cex = 1.8, col = "#d1495b")
  })

  selected <- reactive({
    out <- practice
    if (input$shift != "all") out <- out[out$shift == input$shift, , drop = FALSE]
    out$status <- classify_minutes(out$minutes, input$threshold)
    out
  })
  output$syntax_summary <- renderText({
    tab <- table(selected()$status)
    sprintf("기준 %d분 · fast %d · slow %d · missing %d",
            input$threshold, tab[["fast"]], tab[["slow"]], tab[["missing"]])
  })
  output$syntax_table <- renderTable(selected(), striped = TRUE, bordered = TRUE)
  output$syntax_plot <- renderPlot({
    d <- selected()
    cols <- c(fast = "#2a9d8f", slow = "#e76f51", missing = "#9aa0a6")
    plot(d$units, d$minutes, pch = 19, cex = 1.4,
         col = cols[as.character(d$status)], xlab = "Units", ylab = "Minutes",
         main = "Threshold classification")
    abline(h = input$threshold, lty = 2)
  })
}

shinyApp(ui = ui, server = server)
