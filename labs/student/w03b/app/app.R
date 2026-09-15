# 공통 함수 안내: https://github.com/lunalab-ai/regre/blob/main/src/API.md
# source(path)는 R 정의 파일을 현재 환경에 읽어 들입니다(모델 학습 아님).
# classify_minutes(minutes, threshold=45): 숫자 벡터 -> fast/slow/missing ordered factor.
# threshold 이하는 fast, 초과는 slow, NA/NaN은 missing이며 입력을 변경하지 않습니다.
# summarize_by_shift(data): shift/minutes 열 -> shift/n_observed/mean_minutes 표.
# 평균은 결측 제외, 전부 결측인 집단은 NaN. 작은 예: c(30,50,NA) -> fast,slow,missing.
library(shiny)
slr_path <- file.path("..", "data", "slr-tools.R")
if (!file.exists(slr_path)) slr_path <- file.path("data", "slr-tools.R")
source(slr_path)
# W03B API and fixed source version:
# https://github.com/lunalab-ai/regre/blob/2026-fall-w03b/src/slr-api.md
# fit_repair: complete numeric Units/Minutes data -> fitted lm.
# coefficient_inference: fitted lm + level + null slope -> two-row t/CI table.
# No network/install/data mutation; exact inference needs the model assumptions.
association_path <- file.path("..", "data", "association-tools.R")
if (!file.exists(association_path)) association_path <- file.path("data", "association-tools.R")
source(association_path)

# 공개 공통 함수: 로컬 저장소와 브라우저 export 위치를 모두 지원합니다.
tools_path <- file.path("..", "data", "r-syntax-tools.R")
if (!file.exists(tools_path)) tools_path <- file.path("data", "r-syntax-tools.R")
source(tools_path)

repair_path <- file.path("..", "data", "Computer.Repair.txt")
if (!file.exists(repair_path)) repair_path <- file.path("data", "Computer.Repair.txt")
practice_path <- file.path("..", "data", "w02b-observations.csv")
if (!file.exists(practice_path)) practice_path <- file.path("data", "w02b-observations.csv")

repair <- read.table(repair_path, header = TRUE)
practice <- read.csv(practice_path, na.strings = "", stringsAsFactors = FALSE)
model <- fit_repair(repair)

ui <- fluidPage(
  tags$head(tags$style(HTML("@media (max-width: 700px) {.col-sm-4,.col-sm-8{width:100%;} body{font-size:16px;}}"))),
  tags$head(tags$style(HTML("#inference_table th,#inference_table td{white-space:nowrap;}"))),
  titlePanel("회귀분석 누적 실험실"),
  tabsetPanel(
    tabPanel("계수 추론",
      sidebarLayout(
        sidebarPanel(
          selectInput("ci_level", "신뢰수준", choices=c("90%"="0.90","95%"="0.95","99%"="0.99"), selected="0.95"),
          # L5-UI: add the new ci_custom input here (keep the comma).
          numericInput("null_slope", "귀무가설의 기울기 (분/개)", value=0, min=-100, max=100, step=1),
          helpText("자료와 계수는 고정합니다. 기울기 귀무값은 검정에, 신뢰수준은 구간과 판단 유의수준에 반영됩니다."),
          helpText("선형 평균·독립·등분산·정규오차 가정 아래의 계수 추론입니다. 개별 수리시간의 예측구간이 아닙니다.")
        ),
        mainPanel(textOutput("inference_level"),
                  div(style="overflow-x:auto;max-width:100%;",tableOutput("inference_table")),
                  textOutput("inference_decision"),plotOutput("inference_plot",height="360px"))
      )
    ),
    tabPanel("관계 탐색",
      sidebarLayout(
        sidebarPanel(
          selectInput("association_dataset", "자료", choices=c("컴퓨터 수리"="repair", "제곱 곡선"="curve", "Anscombe 1"="anscombe1", "Anscombe 2"="anscombe2", "Anscombe 3"="anscombe3", "Anscombe 4"="anscombe4")),
          selectInput("time_unit", "수리시간 단위", choices=c("분"="minutes","초"="seconds"), selected="minutes"),
          checkboxInput("show_means", "평균선 표시", TRUE),
          helpText("단위 선택은 수리 자료에만 적용됩니다. 함수는 데이터 변환과 요약을 수행하며 모형을 학습하지 않습니다.")
        ),
        mainPanel(textOutput("association_units"),tableOutput("association_table"),plotOutput("association_plot",height="400px"))
      )
    ),
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
  # L5-SERVER: connect both ci_level references below to ci_custom.
  inference_settings <- reactive({
    req(input$ci_level, input$null_slope)
    list(level=as.numeric(input$ci_level),null=input$null_slope)
  })
  inference_result <- reactive({
    settings <- inference_settings()
    coefficient_inference(model,level=settings$level,null_slope=settings$null)
  })
  output$inference_level <- renderText({
    s <- inference_settings()
    sprintf("신뢰수준 %.0f%% · 양측 검정 유의수준 %.2f · n=14, df=12",100*s$level,1-s$level)
  })
  output$inference_table <- renderTable({
    out <- inference_result()
    out$p_value <- formatC(out$p_value,format="e",digits=3)
    out
  },digits=4,striped=TRUE)
  output$inference_decision <- renderText({
    row <- inference_result()[2,]
    sprintf("기울기 %.3f · H0: 기울기 = %.2f · p = %.4g · %s. 비기각은 귀무가설의 증명이 아닙니다.",
            row$estimate,row$null,row$p_value,if(row$reject) "기각" else "기각하지 못함")
  })
  output$inference_plot <- renderPlot({
    row <- inference_result()[2,]
    bounds <- range(c(row$lower,row$upper,row$null))
    pad <- max(diff(bounds)*.10,.2)
    plot(row$estimate,1,xlim=bounds+c(-pad,pad),ylim=c(.5,1.5),yaxt="n",pch=19,
         xlab="Slope (minutes / part)",ylab="",main="Coefficient interval, not a prediction interval")
    segments(row$lower,1,row$upper,1,lwd=4,col="#2864b4")
    points(row$estimate,1,pch=19,cex=1.4)
    abline(v=row$null,col="#d25340",lty=2)
    legend("top",legend=c("Coefficient CI","Null slope"),lty=c(1,2),
           col=c("#2864b4","#d25340"),bty="n",horiz=TRUE)
  })
  association_current <- reactive({
    req(input$association_dataset, input$time_unit)
    association_data(repair, input$association_dataset, input$time_unit)
  })
  association_result <- reactive({
    d <- association_current()
    association_summary(d$X,d$Y)
  })
  output$association_units <- renderText({
    if (input$association_dataset=="repair") paste("X: Units / Y:",input$time_unit)
    else "X, Y: demonstration data (time unit selection is not applied)"
  })
  output$association_table <- renderTable(association_result(),digits=4)
  output$association_plot <- renderPlot({
    d <- association_current()
    plot(d$X,d$Y,pch=19,xlab="X",ylab=if(input$association_dataset=="repair") input$time_unit else "Y", main="Association explorer")
    if (isTRUE(input$show_means)) abline(v=mean(d$X),h=mean(d$Y),lty=2)
  })
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
