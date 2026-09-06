# 이 파일에는 의도적으로 네 가지 오류가 있습니다.
# 원본을 보존하고 my_debug_app.R로 복사한 뒤 수정하세요.

library(shiny)

# 오류 1: 파일 경로와 파일명이 틀렸습니다.
data_path <- "ComputerRepair.txt"
repair <- read.table(data_path, header = TRUE)
model <- lm(Minutes ~ Units, data = repair)

ui <- fluidPage(
  titlePanel("디버깅 회귀 앱"),
  sliderInput(
    inputId = "Units",  # 오류 2: 서버에서 참조하는 입력 ID와 대소문자가 다릅니다.
    label = "수리할 부품 수",
    min = 1,
    max = 15,
    value = 7,
    step = 1
  ),
  textOutput("prediction"),
  plotOutput("regression_plot")
)

server <- function(input, output, session) {
  predicted_minutes <- reactive({
    # 오류 3: 새 데이터의 열 이름이 모형이 요구하는 이름과 다릅니다.
    new_job <- data.frame(Unit = input$units)
    predict(model, newdata = new_job)
  })

  output$prediction <- renderText({
    # 오류 4: reactive 값을 사용할 때 괄호가 필요합니다.
    sprintf("예상 수리시간: %.1f분", predicted_minutes)
  })

  output$regression_plot <- renderPlot({
    plot(Minutes ~ Units, data = repair, pch = 19)
    abline(model, lwd = 2)
  })
}

shinyApp(ui = ui, server = server)
