library(shiny)

# 데이터와 모형 -----------------------------------------------------------
data_path <- file.path("..", "data", "Computer.Repair.txt")
if (!file.exists(data_path)) {
  stop("데이터 파일을 찾을 수 없습니다: ", data_path)
}

repair <- read.table(data_path, header = TRUE)
model <- lm(Minutes ~ Units, data = repair)

# 사용자 화면 -------------------------------------------------------------
ui <- fluidPage(
  titlePanel("수리할 부품 수로 수리시간 예측하기"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "units",
        label = "수리할 부품 수",
        min = 1,
        max = 15,
        value = 7,
        step = 1
      ),
      helpText("반응변수 Y = Minutes, 설명변수 X = Units"),
      helpText("1주차에는 앱의 입력–모형–출력 연결을 먼저 확인합니다.")
    ),
    mainPanel(
      h3(textOutput("prediction")),
      plotOutput("regression_plot", height = "480px"),
      h4("미리보기 모형의 계수"),
      verbatimTextOutput("coefficients")
    )
  )
)

# 서버 로직 ---------------------------------------------------------------
server <- function(input, output, session) {
  predicted_minutes <- reactive({
    new_job <- data.frame(Units = input$units)
    as.numeric(predict(model, newdata = new_job))
  })

  output$prediction <- renderText({
    sprintf("예상 수리시간: %.1f분", predicted_minutes())
  })

  output$coefficients <- renderPrint({
    coef(model)
  })

  output$regression_plot <- renderPlot({
    plot(
      Minutes ~ Units,
      data = repair,
      pch = 19,
      xlab = "수리할 부품 수 (Units)",
      ylab = "수리 시간 (Minutes)",
      main = "관측값, 회귀직선과 현재 예측"
    )
    abline(model, lwd = 2)
    points(input$units, predicted_minutes(), pch = 19, cex = 1.8)
    segments(
      x0 = input$units,
      y0 = par("usr")[3],
      x1 = input$units,
      y1 = predicted_minutes(),
      lty = 2
    )
  })
}

shinyApp(ui = ui, server = server)
