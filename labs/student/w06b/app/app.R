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
prediction_path <- file.path("..", "data", "prediction-tools.R")
if (!file.exists(prediction_path)) prediction_path <- file.path("data", "prediction-tools.R")
source(prediction_path)
# W04A API: https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-api.md
# prediction_intervals: fitted lm + numeric Units + level + kind -> ordered interval rows.
# regression_fit_summary: unweighted lm -> one row with SSE, df and explicit R2 baseline.
# No refit in either helper, no network or input mutation. Units: parts/minutes.
origin_model <- lm(Minutes~0+Units,data=repair)
mean_model <- lm(Minutes~1,data=repair)


# W05A API: https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-api.md
# Each helper links to the exact definition. Percentage changes are percentage points.
source(file.path(dirname(slr_path), "mlr-tools.R"))
attitude_data <- datasets::attitude
attitude_fit <- fit_attitude(attitude_data)
attitude_comparison <- compare_attitude_models(attitude_data)
deviation_fit <- lm(y~x,data=four_points())
deviation_summary <- ss_decomposition(deviation_fit)

source(file.path(dirname(slr_path), "mlr-inference.R"))
w5b_fit2 <- lm(rating~complaints+learning,data=attitude_data)
w5b_fit6 <- lm(rating~.,data=attitude_data)
w5b_scaling <- mlr_scaling(attitude_data)

source(file.path(dirname(slr_path),"diagnostics.R"))
w6_res <- diag_residuals(w5b_fit2)
w6_ham <- diag_hamilton(file.path(dirname(slr_path),"hamilton.csv"))
w6_ham_summary <- diag_hamilton_fits(w6_ham)
w6_patterns <- diag_patterns()
source(file.path(dirname(slr_path),"review-foundations.R"))
w6b_data <- review_data()
ui <- fluidPage(
  tags$head(tags$style(HTML("@media (max-width: 700px) {.col-sm-4,.col-sm-8{width:100%;} body{font-size:16px;}}"))),
  tags$head(tags$style(HTML("#inference_table th,#inference_table td{white-space:nowrap;}"))),
  titlePanel("회귀분석 누적 실험실"),
  tabsetPanel(

    tabPanel("W06B 기초 복습",
      p("같은 자료에서 선택 조건·결측 처리·단위를 바꾸면 어떤 숫자가 달라질까요? 먼저 예상하고 실행하세요. 아래8건은 수업용 가상 자료입니다."),
      sidebarLayout(sidebarPanel(
        selectInput("w6b_shift","선택할 조",choices=c("전체"="all","오전"="AM","오후"="PM")),
        numericInput("w6b_limit","관측 시간 상한 (분)",min=0,max=100,value=100,step=1),
        selectInput("w6b_missing","결측 처리",choices=c("결측 제외 · 관측값 평균"="exclude","결측 유지"="keep","0 가정 비교 (권장 대체법 아님)"="zero")),
        selectInput("w6b_scale","표시 단위",choices=c("분"=1,"초"=60)),
        helpText("상한을 비교할 수 없는 결측 행은 남겨 두며, 결측 처리 선택에서 그 영향을 확인합니다."),
        tags$a(href="https://github.com/lunalab-ai/regre/blob/2026-fall-w06b/src/review-foundations-api.md",target="_blank","함수 설명 및 실제 정의 바로가기"),
        uiOutput("w6b_download_ui")
      ),mainPanel(
        h4("① 선택된 행과 원자료 단위"),tableOutput("w6b_rows"),
        h4("② 합 / 분모 = 평균"),textOutput("w6b_explain"),tableOutput("w6b_summary_table"),
        plotOutput("w6b_plot",height="260px"),
        h4("③ 기본 R 코드로 같은 계산 읽기"),verbatimTextOutput("w6b_code"),
        p("온라인 R에서 scale=1을60으로 직접 바꾸고 재실행하세요. 평균과 건수를 비교하고 수정한 코드를 저장합니다."),
        tags$a(href="https://lunalab-ai.github.io/regre/w06b.html",target="_blank","내 코드를 수정·실행·다운로드"),
        p("관찰 기록: 내 예상 → 실제 분모와 평균 → 차이의 이유 → 어떤 대상의 평균인가?")))
    ),

    tabPanel("W06A 잔차",
      p("30개 부서의 같은 complaints + learning 모형입니다. 점을 클릭하거나 부서 번호를 바꾸면 두 그림과 표가 함께 바뀝니다."),
      sidebarLayout(sidebarPanel(
        numericInput("w6_row","강조할 부서 (행 번호, 시간 아님)",value=1,min=1,max=30,step=1),
        selectInput("w6_kind","비교할 잔차",choices=c("보통 잔차 (%p)"="raw","내적 표준화 (무단위)"="internal","외적 표준화 (무단위)"="external"),selected="internal"),
        helpText("보통 잔차는 관측값−적합값입니다. 내적/외적은 분모의 오차 규모 추정에 해당 관측을 포함하는지가 다릅니다."),
        tags$a(href="https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics-api.md",target="_blank","함수 입력·출력 및 실제 정의 바로가기")
      ),mainPanel(textOutput("w6_message"),tableOutput("w6_table"),
        plotOutput("w6_observed",height="280px",click="w6_observed_click"),
        plotOutput("w6_residual",height="280px",click="w6_residual_click"),
        h4("마지막 코드 활동 L8"),textOutput("w6_student_value")))
    ),
    tabPanel("W06A 회전",
      p("Hamilton 15개 구성 관측: 같은 점을 다른 방향에서 봅니다. 화면 좌표만 바뀌며 데이터와 적합식은 그대로입니다."),
      sidebarLayout(sidebarPanel(
        numericInput("w6_azimuth","방위각 (도)",value=35,min=-360,max=360,step=15),
        numericInput("w6_elevation","고도각 (도)",value=20,min=-90,max=90,step=10),
        actionButton("w6_rotate","방위각 +15도"),
        numericInput("w6_ham_row","강조할 Hamilton 관측",value=4,min=1,max=15,step=1),
        helpText("X1/X2/Y를 각각 표준화한 뒤 직교투영합니다. u/v는 무단위 화면 좌표이며 원래 변수 축이 아닙니다.")
      ),mainPanel(textOutput("w6_rotation_message"),tableOutput("w6_ham_table"),
        plotOutput("w6_rotation",height="390px",click="w6_rotation_click"),tableOutput("w6_ham_fits")))
    ),
    tabPanel("W06A 패턴",
      p("§5.6의 목적 지도를 이해하는 추가 연결 예제입니다. 아래는 실제 부서 자료가 아니라 생성 조건을 정한 모의자료입니다."),
      selectInput("w6_pattern","보고 싶은 패턴",choices=c("불규칙 띠"="band","곡선"="curve","퍼짐 변화"="fan","수집 순서 패턴"="order")),
      plotOutput("w6_pattern_plot",height="380px"),textOutput("w6_pattern_message"),
      p("관찰한 사실 / 가능한 설명 / 추가 확인을 각각 한 문장으로 적으세요. 그림 하나로 가정이나 원인을 확정하거나 점을 자동 삭제하지 않습니다.")
    ),

    tabPanel("W05B 단위",
      p("같은 30개 부서의 complaints + learning 모형입니다. 단위를 바꾼 계수와 원래 단위로 복원한 예측을 비교합니다."),
      sidebarLayout(sidebarPanel(
        selectInput("w5b_scale","표현할 좌표",choices=c("원래 단위"="original","X 중심화"="centered","X·Y 표준화"="standardized","X·Y 단위길이"="unit_length")),
        helpText("중심화는 원점, 척도화는 단위를 바꿉니다. 절편 포함 OLS의 동일한 예측함수 집합입니다."),
        tags$a(href="https://github.com/lunalab-ai/regre/blob/2026-fall-w05b/src/mlr-inference-api.md",target="_blank","함수 입력·출력 및 정의 바로가기")
      ),mainPanel(tableOutput("w5b_scaling_table"),textOutput("w5b_scaling_message"),plotOutput("w5b_scaling_plot",height="350px")))
    ),
    tabPanel("W05B 검정",
      p("귀무가설을 먼저 고른 뒤 비교하기를 누르세요. 전체 검정과 부분 검정의 축소모형은 다릅니다."),
      sidebarLayout(sidebarPanel(
        selectInput("w5b_test","검정할 가설",choices=c("전체: 여섯 기울기 모두 0"="global","부분: 추가 네 기울기 모두 0"="partial","두 기울기 동일"="equal","두 기울기 합 = 1"="sum"),selected="partial"),
        actionButton("w5b_run","비교하기",class="btn-primary"),
        helpText("동일성·합 제약은 complaints + learning 두 변수 모형 안에서 검정합니다. 비기각은 가설의 입증이 아닙니다.")
      ),mainPanel(textOutput("w5b_test_question"),tableOutput("w5b_test_result"),textOutput("w5b_test_message"),plotOutput("w5b_test_plot",height="330px")))
    ),
    tabPanel("W05B 예측",
      p("한 관측은 부서 하나입니다. 같은 조건의 평균반응 CI와 다음 부서 한 곳의 PI를 비교합니다."),
      sidebarLayout(sidebarPanel(
        numericInput("w5b_x1","complaints (%)",value=mean(attitude_data$complaints),min=0,max=100,step=1),
        numericInput("w5b_x3","learning (%)",value=mean(attitude_data$learning),min=0,max=100,step=1),
        selectInput("w5b_level","구간 수준",choices=c("90%"=".90","95%"=".95","99%"=".99"),selected=".95"),
        selectInput("w5b_kind","설명할 구간",choices=c("평균반응 CI"="confidence","새 부서 PI"="prediction"),selected="confidence"),
        numericInput("w5b_noise","가상 오차 배율 (1=실제 추정 규모)",value=1,min=.25,max=3,step=.25),
        helpText("배율을 바꾸는 것은 실제 재적합이 아닙니다. 같은 오차 규모가 구간 폭에 미치는 영향을 비교하는 시나리오입니다."),
        tags$a(href="https://lunalab-ai.github.io/regre/w05b.html",target="_blank","L8 코드 수정 안내로 이동")
      ),mainPanel(textOutput("w5b_prediction_message"),textOutput("w5b_support_message"),
          div(style="overflow-x:auto;",tableOutput("w5b_prediction_table")),
          plotOutput("w5b_prediction_plot",height="340px"),
          h4("내가 연결할 출력"),textOutput("w5b_student_width")))
    ),

    tabPanel("편차와 R²",
      p("같은 네 점에서 평균 예측과 회귀 예측을 비교합니다. 회색=평균 기준, 청록=설명편차, 빨강=잔차."),
      sidebarLayout(
        sidebarPanel(
          selectInput("dev_point","선택할 관측",choices=1:4,selected=4),
          selectInput("dev_mode","보여 줄 예측",choices=c("세 편차 함께"="three","평균 예측"="mean","회귀 예측"="fit")),
          numericInput("dev_intercept","후보 절편",value=1,step=.2),
          numericInput("dev_slope","후보 기울기",value=1.2,step=.1),
          helpText("후보의 SSE와 최소제곱 SSE=0.8을 비교하세요. 후보를 바꾸어도 오른쪽 OLS 편차 정의는 바뀌지 않습니다."),
          tags$a(href="https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-api.md",target="_blank","공통 함수 설명·정의 바로가기")
        ),
        mainPanel(
          textOutput("dev_message"),
          tableOutput("dev_table"),
          plotOutput("dev_plot",height="380px"),
          h4("전체 제곱오차: 평균 → 최소제곱 회귀"),
          tableOutput("dev_summary"),
          textOutput("candidate_message"),
          plotOutput("candidate_plot",height="260px")
        )
      )
    ),
    tabPanel("다중회귀",
      p("30개 부서의 긍정 응답 비율(%). 모형 비교와 두 변수 조건부 예측을 구분해서 읽습니다."),
      sidebarLayout(
        sidebarPanel(
          selectInput("mlr_model","비교할 모형",choices=c("평균만"="mean","complaints"="one","complaints + privileges"="two","여섯 설명변수"="six"),selected="two"),
          numericInput("mlr_x1","두 변수 예측: complaints (%)",min=0,max=100,value=60,step=1),
          numericInput("mlr_x2","고정할 privileges (%)",min=0,max=100,value=50,step=1),
          helpText("입력은 두 변수 모형의 예측에 사용됩니다. 모형 선택은 위 비교 표와 계수 표에만 적용됩니다."),
          helpText("다른 변수를 같은 값으로 유지한 비교입니다. 인과효과나 개인 단위 변화로 해석하지 않습니다."),
          tags$a(href="https://lunalab-ai.github.io/regre/w05a.html",target="_blank","R 실습 및 L6 코드 수정 활동")
        ),
        mainPanel(
          h4("같은 행에서 모형 비교"),
          div(style="overflow-x:auto;",tableOutput("mlr_comparison")),
          textOutput("mlr_selected_message"),tableOutput("mlr_coefficients"),
          h4("두 변수 모형의 조건부 예측"),textOutput("mlr_prediction_message"),
          textOutput("mlr_student_extension"),
          plotOutput("mlr_slice",height="350px"),
          h4("complaints를 양쪽에서 제거한 잔차 회귀"),
          textOutput("mlr_partial_message"),plotOutput("mlr_partial",height="320px")
        )
      )
    ),
    tabPanel("예측과 구간",
      sidebarLayout(
        sidebarPanel(
          numericInput("prediction_x","예측할 부품 수",min=1,max=15,value=4,step=1),
          selectInput("prediction_level","구간 수준",choices=c("90%"="0.90","95%"="0.95","99%"="0.99"),selected="0.95"),
          selectInput("interval_kind","구간의 대상",choices=c("평균반응"="confidence","새 관측 한 건"="prediction"),selected="confidence"),
          # W04A-L6-UI: add kind_custom selectInput here, with a trailing comma.
          helpText("같은 점예측, 다른 불확실성입니다. 관측 Units 범위는 1–10입니다."),
          helpText("구간 곡선은 점별 구간입니다. 외삽에서 모형 타당성을 보증하지 않습니다.")
        ),
        mainPanel(textOutput("interval_message"),
          div(style="overflow-x:auto;max-width:100%;",tableOutput("interval_table")),
          plotOutput("interval_plot",height="420px"))
      )
    ),
    tabPanel("적합성 비교",
      sidebarLayout(
        sidebarPanel(
          selectInput("model_kind","그림의 모형",choices=c("절편 포함"="intercept","원점 회귀"="origin","절편만"="mean")),
          helpText("R2의 mean/zero 기준을 먼저 확인하세요. 서로 다른 기준의 R2를 크기만으로 비교하지 않습니다.")
        ),
        mainPanel(div(style="overflow-x:auto;max-width:100%;",tableOutput("model_table")),
                  plotOutput("model_plot",height="400px"))
      )
    ),
    tabPanel("계수 추론",
      sidebarLayout(
        sidebarPanel(
          selectInput("ci_level", "신뢰수준", choices=c("90%"="0.90","95%"="0.95","99%"="0.99"), selected="0.95"),
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

  w6b_selected <- reactive({
    req(input$w6b_shift,input$w6b_limit)
    review_select(w6b_data,input$w6b_shift,input$w6b_limit)
  })
  w6b_result <- reactive({
    req(input$w6b_missing,input$w6b_scale)
    review_summary(w6b_selected()$minutes,input$w6b_missing,as.numeric(input$w6b_scale))
  })
  output$w6b_rows <- renderTable(w6b_selected())
  output$w6b_summary_table <- renderTable(w6b_result(),digits=4)
  output$w6b_explain <- renderText({
    s<-w6b_result();unit<-if(as.numeric(input$w6b_scale)==60) "초" else "분"
    paste0("전체 ",s$n_total,"건 / 관측 ",s$n_observed,"건 / 결측 ",s$n_missing,
      "건. 합 ",if(is.na(s$sum_used)) "알 수 없음" else round(s$sum_used,4),
      " / 분모 ",s$denominator," → 평균 ",if(is.na(s$mean)) "계산 불가" else paste(round(s$mean,4),unit),
      if(input$w6b_missing=="zero") ". 0 가정은 비교용이며 관측값 평균과 다른 질문입니다." else ". 원자료는 변경되지 않습니다.")
  })
  output$w6b_plot <- renderPlot({
    d<-w6b_selected();v<-d$minutes*as.numeric(input$w6b_scale)
    if(!nrow(d)||all(is.na(v))) {plot.new();text(.5,.5,"No observed values: mean unavailable");return(invisible(NULL))}
    barplot(v,names.arg=d$id,col="#087f8c",ylab=if(as.numeric(input$w6b_scale)==60) "Seconds" else "Minutes",
      main="Observed values (NA is not an observed zero)")
  })
  output$w6b_code <- renderText({
    paste0("selected <- review_select(demo, shift=\"",input$w6b_shift,"\", limit=",input$w6b_limit,
       ")\nreview_summary(selected$minutes, missing=\"",input$w6b_missing,"\", scale=",input$w6b_scale,")")
  })
  output$w6b_download_ui <- renderUI({
    d<-w6b_selected();d$selected_shift<-rep(input$w6b_shift,nrow(d))
    d$limit_minutes<-rep(input$w6b_limit,nrow(d));d$missing_policy<-rep(input$w6b_missing,nrow(d))
    d$display_scale<-rep(as.numeric(input$w6b_scale),nrow(d))
    csv <- paste(capture.output(write.csv(d,row.names=FALSE,na="NA")),collapse=intToUtf8(10))
    tags$a(href=paste0("data:text/csv;charset=utf-8,",utils::URLencode(csv,reserved=TRUE)),
      download="w06b-selected.csv",class="btn btn-default",
      icon("download"),"현재 선택 CSV 다운로드")
  })


  w6_selected <- reactive({
    req(input$w6_row,input$w6_kind)
    validate(need(length(input$w6_row)==1 && is.finite(input$w6_row) && input$w6_row==as.integer(input$w6_row) && input$w6_row>=1 && input$w6_row<=30,"1–30 사이의 정수 부서 번호를 입력하세요."))
    w6_res[input$w6_row,,drop=FALSE]
  })
  output$w6_message <- renderText({
    a<-w6_selected();sprintf("부서 %d · 관측 %.3f%% · 적합 %.3f%% · 보통 잔차 %.3f%%p · %s %.3f",a$row,a$observed,a$fitted,a$raw,input$w6_kind,a[[input$w6_kind]])
  })
  output$w6_table <- renderTable({
    a<-w6_selected();data.frame(quantity=c("보통 잔차 e (%p)","지레값 h","전체 s (%p)","제외 추정 s_i (%p)","내적 r (무단위)","외적 r* (무단위)"),
      value=c(a$raw,a$h,a$s,a$s_deleted,a$internal,a$external))
  },digits=5)
  output$w6_observed <- renderPlot({
    a<-w6_selected();plot(w6_res$fitted,w6_res$observed,pch=19,col="#087f8c",xlab="Fitted rating (%)",ylab="Observed rating (%)",main="Same department: observed - fitted")
    abline(0,1,lty=2);segments(a$fitted,a$fitted,a$fitted,a$observed,col="#d95d52",lwd=4)
    points(a$fitted,a$observed,pch=19,col="#d95d52",cex=1.6);text(a$fitted,a$observed,a$row,pos=3)
  })
  output$w6_residual <- renderPlot({
    a<-w6_selected();v<-w6_res[[input$w6_kind]]
    plot(w6_res$fitted,v,pch=19,col="#087f8c",xlab="Fitted rating (%)",ylab=input$w6_kind,main="Same department: chosen residual")
    abline(h=0,lty=2);points(a$fitted,a[[input$w6_kind]],pch=19,col="#d95d52",cex=1.6);text(a$fitted,a[[input$w6_kind]],a$row,pos=3)
  })
  observeEvent(input$w6_observed_click,{
    a<-nearPoints(w6_res,input$w6_observed_click,xvar="fitted",yvar="observed",maxpoints=1)
    if(nrow(a)) updateNumericInput(session,"w6_row",value=a$row[1])
  })
  observeEvent(input$w6_residual_click,{
    req(input$w6_kind);a<-nearPoints(w6_res,input$w6_residual_click,xvar="fitted",yvar=input$w6_kind,maxpoints=1)
    if(nrow(a)) updateNumericInput(session,"w6_row",value=a$row[1])
  })
  output$w6_student_value <- renderText({
    req(input$w6_kind);w6_selected()
    # W06A-L8: connect the selected row and selected residual column here.
    "L8: 선택한 잔차값이 소수 셋째자리로 나타나도록 이 문장을 수정하세요."
  })
  w6_projection <- reactive({
    req(!is.null(input$w6_azimuth),!is.null(input$w6_elevation))
    validate(need(all(is.finite(c(input$w6_azimuth,input$w6_elevation))),"유한한 각도를 입력하세요."))
    diag_project(w6_ham,input$w6_azimuth,input$w6_elevation)
  })
  w6_ham_selected <- reactive({
    req(input$w6_ham_row)
    validate(need(is.finite(input$w6_ham_row) && input$w6_ham_row==as.integer(input$w6_ham_row) && input$w6_ham_row>=1 && input$w6_ham_row<=15,"1–15 정수를 입력하세요."))
    input$w6_ham_row
  })
  observeEvent(input$w6_rotate,{req(input$w6_azimuth);updateNumericInput(session,"w6_azimuth",value=((input$w6_azimuth+15+180)%%360)-180)})
  output$w6_rotation_message <- renderText({
    a<-w6_projection();i<-w6_ham_selected()
    sprintf("관측 %d · 방위각 %.0f도 · 고도각 %.0f도 · 화면 u=%.3f, v=%.3f. 아래 원자료 값은 유지됩니다.",i,input$w6_azimuth,input$w6_elevation,a$u[i],a$v[i])
  })
  output$w6_ham_table <- renderTable(w6_ham[w6_ham_selected(),,drop=FALSE],digits=2)
  output$w6_ham_fits <- renderTable(w6_ham_summary,digits=6)
  output$w6_rotation <- renderPlot({
    a<-w6_projection();i<-w6_ham_selected();lim<-max(sqrt(rowSums(a[,2:4]^2)))+.25
    plot(a$u,a$v,pch=19,col="#087f8c",xlim=c(-lim,lim),ylim=c(-lim,lim),asp=1,xlab="Screen u (scaled)",ylab="Screen v (scaled)",main="Hamilton: same data, rotated view")
    points(a$u[i],a$v[i],pch=19,col="#d95d52",cex=1.7);text(a$u[i],a$v[i],i,pos=3)
  })
  observeEvent(input$w6_rotation_click,{
    a<-nearPoints(w6_projection(),input$w6_rotation_click,xvar="u",yvar="v",maxpoints=1)
    if(nrow(a)) updateNumericInput(session,"w6_ham_row",value=a$row[1])
  })
  output$w6_pattern_plot <- renderPlot({
    req(input$w6_pattern);a<-w6_patterns[[input$w6_pattern]]
    plot(if(input$w6_pattern=="order")a$order else a$fitted,a$residual,pch=19,col="#087f8c",xlab=if(input$w6_pattern=="order")"Collection order" else "Fitted",ylab="Residual",main=paste("Simulation:",input$w6_pattern));abline(h=0,lty=2)
  })
  output$w6_pattern_message <- renderText({
    req(input$w6_pattern)
    switch(input$w6_pattern,band="무작위 띠처럼 보이더라도 모든 가정이 참이라고 입증한 것은 아닙니다.",curve="곡선은 평균함수 형태를 검토할 단서입니다.",fan="퍼짐 변화는 등분산을 검토할 단서이며 계수 편향을 자동으로 뜻하지 않습니다.",order="여기서는 수집 순서가 명시된 모의자료입니다. attitude 행번호를 시간으로 해석하지 마세요.")
  })


  output$w5b_scaling_table <- renderTable(w5b_scaling$coefficients,digits=6)
  output$w5b_scaling_message <- renderText({
    req(input$w5b_scale)
    diff <- max(abs(w5b_scaling$fitted_original_units[[input$w5b_scale]]-fitted(w5b_fit2)))
    sprintf("선택: %s · 원래 rating 단위로 복원한 예측의 최대 차이 %.2e. 예측이 달라진 것이 아니라 좌표가 바뀌었습니다.",input$w5b_scale,diff)
  })
  output$w5b_scaling_plot <- renderPlot({
    req(input$w5b_scale)
    plot(fitted(w5b_fit2),w5b_scaling$fitted_original_units[[input$w5b_scale]],
         pch=19,col="#087f8c",xlab="Original fitted rating (%)",ylab="Restored fitted rating (%)",main="Same predictions after restoring units")
    abline(0,1,col="#d95d52",lwd=2)
  })
  w5b_test <- eventReactive(input$w5b_run,{
    req(input$w5b_test)
    switch(input$w5b_test,
      global=list(question="평균만 모형 vs 여섯 변수: 여섯 기울기 모두 0",result=mlr_nested_f(lm(rating~1,data=attitude_data),w5b_fit6)),
      partial=list(question="complaints + learning vs 여섯 변수: 추가 네 기울기 모두 0",result=mlr_nested_f(w5b_fit2,w5b_fit6)),
      equal=list(question="두 변수 모형: complaints 계수 = learning 계수",result=mlr_linear_test(w5b_fit2,c(0,1,-1))),
      sum=list(question="두 변수 모형: complaints 계수 + learning 계수 = 1",result=mlr_linear_test(w5b_fit2,c(0,1,1),r=1)))
  },ignoreNULL=FALSE)
  output$w5b_test_question <- renderText(w5b_test()$question)
  output$w5b_test_result <- renderTable(w5b_test()$result,digits=6)
  output$w5b_test_message <- renderText({
    a <- w5b_test()$result
    sprintf("F(%d, %d) = %.4f · p = %.6g · 5%%에서 %s. 비기각은 계수가 정확히 귀무값이라는 증명이 아닙니다.",a$q,a$df_full,a$F,a$p,if(a$p<.05)"기각" else "기각하지 못함")
  })
  output$w5b_test_plot <- renderPlot({
    a <- w5b_test()$result;critical<-qf(.95,a$q,a$df_full)
    xmax<-max(critical*1.7,a$F*1.2);x<-seq(.001,xmax,length.out=400)
    plot(x,df(x,a$q,a$df_full),type="l",col="#3658a7",lwd=2,xlab="F statistic",ylab="Null density",main="Observed F and the 5% upper-tail cutoff")
    abline(v=critical,col="#62748b",lty=2,lwd=2);abline(v=a$F,col="#d95d52",lwd=3)
    legend("topright",c("Observed F","5% cutoff"),col=c("#d95d52","#62748b"),lty=c(1,2),bty="n")
  })
  w5b_intervals <- reactive({
    req(!is.null(input$w5b_x1),!is.null(input$w5b_x3),input$w5b_level,!is.null(input$w5b_noise))
    xx<-c(input$w5b_x1,input$w5b_x3)
    validate(need(all(is.finite(xx)) && all(xx>=0 & xx<=100),"두 비율을0–100 사이로 입력하세요."),
             need(is.finite(input$w5b_noise) && input$w5b_noise>=.25 && input$w5b_noise<=3,"오차 배율은0.25–3 사이로 입력하세요."))
    mlr_interval_comparison(w5b_fit2,data.frame(complaints=xx[1],learning=xx[2]),
      level=as.numeric(input$w5b_level),noise_multiplier=input$w5b_noise)
  })
  selected_interval <- reactive({
    req(input$w5b_kind);a<-w5b_intervals();a[a$kind==input$w5b_kind,,drop=FALSE]
  })
  output$w5b_prediction_table <- renderTable(w5b_intervals()[c("kind","fit","lower","upper","width","h0")],digits=4)
  output$w5b_prediction_message <- renderText({
    a<-w5b_intervals()
    sprintf("점예측 %.4f%% · %.0f%% 구간 · %s",a$fit[1],100*a$level[1],
      if(a$noise_multiplier[1]==1) "실제 모형의 잔차 오차 규모" else sprintf("가상 오차 배율 %.2f: 실제 재적합 아님",a$noise_multiplier[1]))
  })
  output$w5b_support_message <- renderText({
    a<-w5b_intervals()
    outside<-input$w5b_x1<min(attitude_data$complaints)||input$w5b_x1>max(attitude_data$complaints)||input$w5b_x3<min(attitude_data$learning)||input$w5b_x3>max(attitude_data$learning)
    paste(if(outside)"개별 관측 범위 밖의 입력입니다." else "각 변수의 개별 관측 범위 안입니다.",
      sprintf("h0=%.4f. 개별 범위 검사는 공동 관측 영역이나 모형 타당성의 보증이 아닙니다.",a$h0[1]))
  })
  output$w5b_prediction_plot <- renderPlot({
    a<-w5b_intervals();par(mar=c(4,5,3,1))
    plot(a$fit,2:1,xlim=range(c(a$lower,a$upper)),ylim=c(.5,2.5),yaxt="n",pch=19,xlab="Predicted rating (%)",ylab="",main="Same center, different targets")
    axis(2,at=2:1,labels=c("Mean CI","New PI"),las=1)
    segments(a$lower,2:1,a$upper,2:1,col=c("#087f8c","#d95d52"),lwd=6);points(a$fit,2:1,pch=19)
  })
  output$w5b_student_width <- renderText({
    # W05B-L8: connect selected_interval()$width in the output message.
    "L8: 선택한 구간의 폭을 소수 둘째자리까지 표시하도록 이 출력문을 바꾸세요."
  })


  dev_current <- reactive({
    req(input$dev_point)
    deviation_summary$points[as.integer(input$dev_point),,drop=FALSE]
  })
  output$dev_message <- renderText({
    p <- dev_current()
    sprintf("관측%d: 총편차 %+.1f = 설명편차 %+.1f + 잔차 %+.1f. 설명편차는 예측−평균입니다.",p$id,p$total,p$explained,p$residual)
  })
  output$dev_table <- renderTable({
    p <- dev_current()
    data.frame(observed=p$observed,mean=p$baseline,fitted=p$fitted,
               baseline_sq=p$baseline_sq,residual_sq=p$residual_sq,improvement=p$improvement,check.names=FALSE)
  },digits=2)
  output$dev_plot <- renderPlot({req(input$dev_mode);plot_deviation_story(as.integer(input$dev_point),input$dev_mode)})
  output$dev_summary <- renderTable(deviation_summary$summary[c("SST","SSR","SSE","R2")],digits=2)
  candidate_current <- reactive({
    req(!is.null(input$dev_intercept),!is.null(input$dev_slope))
    validate(need(all(is.finite(c(input$dev_intercept,input$dev_slope))),"유한한 계수를 입력하세요."))
    candidate_line(intercept=input$dev_intercept,slope=input$dev_slope)
  })
  output$candidate_message <- renderText(sprintf("선택한 후보의 SSE %.4f · 최소제곱 SSE 0.8000 · 평균 예측 SSE 8.0000",candidate_current()$SSE))
  output$candidate_plot <- renderPlot({
    p <- candidate_current()$points
    plot(p$x,p$y,pch=19,xlab="x",ylab="y",ylim=range(c(p$y,p$fitted)),main="Chosen candidate, not a new OLS fit")
    lines(p$x,p$fitted,col="#087f8c",lwd=2)
    segments(p$x,p$y,p$x,p$fitted,col="#d95d52",lwd=2)
  })
  mlr_selected <- reactive({
    req(input$mlr_model)
    predictors <- switch(input$mlr_model,mean=character(0),one="complaints",
      two=c("complaints","privileges"),six=setdiff(names(attitude_data),"rating"))
    fit_attitude(attitude_data,predictors)
  })
  output$mlr_comparison <- renderTable(attitude_comparison,digits=4)
  output$mlr_selected_message <- renderText({
    s <- ss_decomposition(mlr_selected())$summary
    sprintf("선택 모형: 계수%d개 · 잔차 자유도%d · SSE %.4f · R² %.4f · 잔차 표준편차 %.4f %%p",s$parameters,s$df,s$SSE,s$R2,sqrt(s$sigma2))
  })
  output$mlr_coefficients <- renderTable({
    b <- coef(mlr_selected());data.frame(term=names(b),estimate=unname(b))
  },digits=5)
  mlr_prediction <- reactive({
    req(!is.null(input$mlr_x1),!is.null(input$mlr_x2))
    validate(need(all(is.finite(c(input$mlr_x1,input$mlr_x2))) &&
      all(c(input$mlr_x1,input$mlr_x2)>=0 & c(input$mlr_x1,input$mlr_x2)<=100),"비율을0–100 사이로 입력하세요."))
    predict_conditions(attitude_fit,input$mlr_x1,input$mlr_x2)
  })
  output$mlr_prediction_message <- renderText({
    p <- mlr_prediction()
    sprintf("complaints %.1f%%, privileges %.1f%% → 예측 rating %.4f%%. %s",p$complaints,p$privileges,p$rating_hat,
      if(p$outside_observed_range) "관측 범위 밖: 외삽에 주의하세요." else "개별 변수 범위 안이며, 공동 지지나 인과성을 보장하지 않습니다.")
  })
  output$mlr_student_extension <- renderText({
    p <- mlr_prediction()
    # L6-OUTPUT: replace this message with a conditional 10-percentage-point prediction difference.
    sprintf("L6: 현재 조건(complaints %.0f%%, privileges %.0f%%)에서 complaints만10%%p 높인 예측 차이를 코드로 연결하세요.",p$complaints,p$privileges)
  })
  output$mlr_slice <- renderPlot({
    p <- mlr_prediction();plot_conditional_slice(attitude_fit,p$privileges)
    points(p$complaints,p$rating_hat,pch=19,col="#d95d52",cex=1.5)
  })
  output$mlr_partial_message <- renderText({
    p <- partial_regression(attitude_data)
    sprintf("두 잔차의 기울기 %.7f = 다중회귀 privileges 계수 %.7f",p$slope,coef(attitude_fit)["privileges"])
  })
  output$mlr_partial <- renderPlot({
    p <- partial_regression(attitude_data)
    plot(p$points$rx,p$points$ry,pch=19,col="#087f8c",xlab="Residual privileges",ylab="Residual rating")
    abline(p$residual_fit,col="#d95d52",lwd=2);abline(h=0,v=0,col="gray70",lty=2)
  })
  # W04A-L6-SERVER: connect the two interval_kind references to kind_custom.
  interval_settings <- reactive({
    req(input$prediction_x,input$prediction_level,input$interval_kind)
    list(x=input$prediction_x,level=as.numeric(input$prediction_level),kind=input$interval_kind)
  })
  interval_result <- reactive({
    s <- interval_settings()
    prediction_intervals(model,s$x,level=s$level,interval=s$kind)
  })
  output$interval_message <- renderText({
    r <- interval_result()
    sprintf("%s · %.0f%% · x=%g · %.3f분 · %s",
      if(r$kind=="confidence") "평균반응 신뢰구간" else "새 관측 예측구간",
      100*r$level,r$Units,r$fit,if(r$extrapolation) "외삽: 관측 범위 밖" else "관측 범위 안")
  })
  output$interval_table <- renderTable(interval_result(),digits=3)
  output$interval_plot <- renderPlot({
    s <- interval_settings()
    g <- prediction_intervals(model,seq(1,15,length.out=121),s$level,s$kind)
    r <- interval_result()
    plot(Minutes~Units,data=repair,pch=19,xlim=c(1,15),ylim=range(c(0,g$lower,g$upper)),
         xlab="Units",ylab="Minutes",main=paste("Pointwise",s$kind,"interval"))
    polygon(c(g$Units,rev(g$Units)),c(g$lower,rev(g$upper)),border=NA,col=adjustcolor("#168c82",alpha.f=.20))
    points(repair$Units,repair$Minutes,pch=19)
    lines(g$Units,g$fit,col="#2864b4",lwd=2)
    abline(v=10,col="#d25340",lty=3)
    segments(r$Units,r$lower,r$Units,r$upper,lwd=4,col="#d25340")
    points(r$Units,r$fit,pch=19,col="#d25340",cex=1.4)
  })
  model_results <- reactive({
    models <- list(intercept=model,origin=origin_model,mean=mean_model)
    do.call(rbind,lapply(names(models),function(k) {
      r <- regression_fit_summary(models[[k]])
      data.frame(model=k,r[,c("df","SSE","RSE","residual_sum","baseline","R_squared","R_squared_centered")])
    }))
  })
  output$model_table <- renderTable(model_results(),digits=4)
  selected_model <- reactive({
    req(input$model_kind)
    switch(input$model_kind,intercept=model,origin=origin_model,mean=mean_model)
  })
  output$model_plot <- renderPlot({
    m <- selected_model()
    plot(Minutes~Units,data=repair,pch=19,xlim=c(0,11),ylim=c(0,180),xlab="Units",ylab="Minutes")
    xx <- seq(0,11,length.out=100)
    lines(xx,predict(m,newdata=data.frame(Units=xx)),col="#2864b4",lwd=2)
    segments(repair$Units,repair$Minutes,repair$Units,fitted(m),col="#d25340")
  })
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
