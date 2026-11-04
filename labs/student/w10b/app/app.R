# W10B public cumulative extension: existing numerical OLS APIs, no answer lookup.
# API contract and exact definitions:
# https://github.com/lunalab-ai/regre/blob/2026-fall-w10b/src/diagnostics-w10b-api.md
library(shiny)
library(MASS)
base_path <- file.path("..", "data", "diagnostics-base-w10b.R")
if (!file.exists(base_path)) base_path <- file.path("data", "diagnostics-base-w10b.R")
data_dir <- dirname(base_path)
source(base_path,encoding="UTF-8")
source(file.path(data_dir,"diagnostics-influence-w10b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-effects-w10b.R"),encoding="UTF-8")
source(file.path(data_dir,"diagnostics-w10b.R"),encoding="UTF-8")
w10b_toy <- read.csv(file.path(data_dir,"hand-five-w10b.csv"))
w10b_ny <- read.csv(file.path(data_dir,"nyrivers-w10b.csv"))
w10b_hills <- read.csv(file.path(data_dir,"scottish-hills-w10b.csv"))
w10b_fit <- lm(y~x,w10b_toy)
w10b_hills_fit <- lm(Time~Distance+Climb,w10b_hills)
w10b_robust <- MASS::rlm(Time~Distance+Climb,w10b_hills,maxit=100)
stopifnot(w10b_robust$converged)
# Preserve the original first-regression activity as an actual cumulative tab.
# fit_repair: numeric Units(parts)/Minutes(minutes), finite complete rows -> OLS lm.
# It fits on the original fourteen observations; no download or data mutation.
source(file.path(data_dir,"slr-tools-w10b.R"),encoding="UTF-8")
w10b_repair <- read.table(file.path(data_dir,"computer-repair-w10b.txt"),header=TRUE)
w10b_repair_fit <- fit_repair(w10b_repair)
course_download <- function(...) {
  tag <- shiny::downloadButton(...)
  if (grepl("emscripten",R.version$platform,fixed=TRUE)) tag$attribs$download <- NULL
  tag
}
ui <- fluidPage(
  tags$head(tags$style(HTML("body{font-size:16px}.trace-scroll{overflow-x:auto}.trace-scroll table{min-width:620px}@media(max-width:700px){.col-sm-4,.col-sm-8{width:100%}}"))),
  titlePanel("W10B · 한 점씩 이해하는 회귀 실험실"),
  p("원자료를 보존하고 분석 사본의 제외 전후를 비교합니다. 선택→예상과 이유→계산→그림→한 문장 설명 순서로 사용하세요."),
  tabsetPanel(
    tabPanel("1. 작은5행과 영향력",
      fluidRow(column(4,
        sliderInput("point_row","제외를 가정할 원래 관측 번호",min=1,max=5,value=4,step=1),
        checkboxInput("show_deleted","제외 후 직선도 함께 표시",TRUE),
        textOutput("point_model"),
        h4("선택 관측 Cook"),textOutput("point_focus"),
        p("Cook은 모든 원래 위치의 변화, DFFITS는 선택 관측 자신의 위치의 변화를 봅니다. 차이의 방향은 전체−제외 후입니다."),
        course_download("trace_csv","두 예측의 차이 표 CSV")),
        column(8,plotOutput("point_plot",height="360px"),
          div(class="trace-scroll",tableOutput("point_trace")),tableOutput("point_metrics"))),
      h4("L06 · 계산과 출력 연결 수정"),
      p("편집기에서 point_focus 출력을 찾아 Cook 필드를 DFFITS로 바꾸고 제목도 맞추세요. Run 후 관측 번호를 바꾸어 부호와 표를 비교합니다. CSV와 편집기 코드 파일을 저장하고 R 세션을 다시 시작해 확인하세요.")),
    tabPanel("2. 교재 NY P-R",
      p("공식20행. Nitrogen은 원자료 척도, ComIndl은 상공업 용지비율(%)입니다. 두 모형의 k를 혼합하지 않습니다."),
      selectInput("ny_model","진단할 모형",c("Nitrogen ~ ComIndl · k=2"="simple","Nitrogen ~ Agr+Forest+Rsdntial+ComIndl · k=5"="full")),
      sliderInput("ny_row","살펴볼 강 번호",min=1,max=20,value=4,step=1),
      textOutput("ny_model_label"),tableOutput("ny_metrics"),
      plotOutput("ny_pr",height="400px"),
      p("가로는 Hadi 잔차 성분 R, 세로는 잠재성 P입니다. 잔차 부호와 오류 확률을 표시하는 그림이 아닙니다. 큰 값은 확인을 시작하는 신호입니다.")),
    tabPanel("3. 한 경주의 AV·CPR",
      p("같은35행, Time 초·Distance 마일·Climb 고도상승 피트. 전체모형 Time ~ Distance + Climb, k=3, df=32. Time은 수집순서가 아닙니다."),
      selectInput("effect_variable","관심 설명변수",c("Distance","Climb")),
      sliderInput("effect_row","좌표를 추적할 경주 번호",min=1,max=35,value=1,step=1),
      radioButtons("effect_kind","그림의 질문",c("AV · 두 보조회귀의 잔차"="av","CPR · 원래 x와 성분+잔차"="cpr"),inline=TRUE),
      textOutput("effect_label"),div(class="trace-scroll",tableOutput("effect_trace")),
      plotOutput("effect_plot",height="430px")),
    tabPanel("4. 처리와 Huber",
      p("관측 오류·단위·모형 형태를 먼저 확인합니다. 가중치는 오류 확률이 아니며 높은 지레값을 자동 방어하지 않습니다."),
      numericInput("huber_u","설명용 표준화 잔차 u",value=2,min=-10,max=10,step=.25),
      tableOutput("huber_trace"),textOutput("robust_status"),tableOutput("robust_weights")),
    tabPanel("첫 회귀 예측",
      p("이전 수업의 14개 수리 기록과 lm 모형을 그대로 이어 사용합니다. 이번 B·C 필수 진도와 구별되는 누적 복습입니다."),
      sliderInput("units","수리할 부품 수",min=1,max=15,value=7,step=1),
      h3(textOutput("prediction")),plotOutput("regression_plot",height="420px"),
      p("입력은 부품 수, 출력은 이 모형에서 예측한 수리시간(분)입니다. 원자료와 기존 공통 함수를 재사용합니다.")),
    tabPanel("이전 누적 기능",
      p("W09B까지의 누적 회귀 실험실을 이어 사용합니다. 이전 배포 원본과 각 차시 URL은 보존되어 있습니다. 이 화면은 인터넷 연결이 필요합니다."),
      tags$a(href="https://lunalab-ai.github.io/regre/apps/w09b/edit/index.html",target="_blank","이전 누적 앱 편집기 열기"),
      tags$iframe(src="https://lunalab-ai.github.io/regre/apps/w09b/",title="W09B까지의 누적 회귀 실험실",width="100%",height="700px",loading="lazy",style="border:1px solid #ccd5df"))
  )
)
server <- function(input,output,session) {
  repair_prediction <- reactive({req(input$units);as.numeric(predict(w10b_repair_fit,newdata=data.frame(Units=input$units)))})
  output$prediction <- renderText(sprintf("예상 수리시간: %.1f분",repair_prediction()))
  output$regression_plot <- renderPlot({
    plot(Minutes~Units,w10b_repair,pch=19,xlab="Parts (Units)",ylab="Repair time (Minutes)",main="Original repair data and current prediction")
    abline(w10b_repair_fit,lwd=2);points(input$units,repair_prediction(),pch=19,cex=1.8,col="#d1495b")
  })
  selected_trace <- reactive({req(input$point_row);w10b_deletion_trace(w10b_fit,as.integer(input$point_row))})
  selected_score <- reactive(selected_trace()$score)
  output$point_model <- renderText(sprintf("교육용5행 · y~x · 전체 n=5,k=2,df=3 / %d번 제외 후 n=4,df=2",input$point_row))
  # W10B_L06_EDIT: one diagnostic field and its displayed label form a connection.
  output$point_focus <- renderText({
    val <- selected_score()$Cook
    sprintf("선택 관측 Cook = %.6f",val)
  })
  output$point_trace <- renderTable({z<-selected_trace();req(!is.null(z$predictions));z$predictions},digits=6)
  output$point_metrics <- renderTable(selected_score()[,c("row","h","raw","Cook","DFFITS")],digits=6)
  output$point_plot <- renderPlot({
    z<-selected_trace();i<-as.integer(input$point_row)
    plot(w10b_toy$x,w10b_toy$y,pch=19,col="#8B98A7",xlim=c(-.3,4.3),ylim=c(.4,4.9),xlab="x (teaching units)",ylab="y (teaching units)",main="Full fit and leave-one-out fit")
    abline(w10b_fit,col="#2363A0",lwd=3);points(w10b_toy$x[i],w10b_toy$y[i],pch=1,col="#933A72",cex=2,lwd=3)
    if(isTRUE(input$show_deleted)&&!is.null(z$predictions)) {
      abline(a=z$coefficients[1],b=z$coefficients[2],col="#C55213",lty=2,lwd=3)
      segments(w10b_toy$x,z$predictions$deleted,w10b_toy$x,z$predictions$full,col="#087F6E",lwd=4)
    }
    text(w10b_toy$x,w10b_toy$y,labels=1:5,pos=3)
    legend("topleft",c("Full fit","Deleted fit","Original omitted observation"),col=c("#2363A0","#C55213","#933A72"),lty=c(1,2,NA),pch=c(NA,NA,1),bty="n")
  })
  output$trace_csv <- downloadHandler(filename=function()paste0("w10b-row-",input$point_row,"-trace.csv"),content=function(file){write.csv(selected_trace()$predictions,file,row.names=FALSE,fileEncoding="UTF-8")})
  ny_fit <- reactive({req(input$ny_model);if(input$ny_model=="simple") lm(Nitrogen~ComIndl,w10b_ny) else lm(Nitrogen~Agr+Forest+Rsdntial+ComIndl,w10b_ny)})
  output$ny_model_label <- renderText(sprintf("현재 모형: n=%d, k=%d, df=%d",nobs(ny_fit()),ny_fit()$rank,df.residual(ny_fit())))
  output$ny_metrics <- renderTable({req(input$ny_row);w10b_pr_trace(ny_fit(),as.integer(input$ny_row))},digits=6)
  output$ny_pr <- renderPlot({z<-diag_influence(ny_fit());i<-as.integer(input$ny_row);plot(z$residual_component,z$potential,pch=19,col="#8B98A7",xlab="Hadi residual component R",ylab="Potential P",main="P-R: x=R, y=P");points(z$residual_component[i],z$potential[i],pch=19,col="#933A72",cex=1.8);text(z$residual_component,z$potential,labels=z$row,pos=3,cex=.7)})
  effect <- reactive({req(input$effect_variable);w10b_effect_trace(w10b_hills_fit,input$effect_variable)})
  output$effect_label <- renderText(sprintf("같은35행·같은 다른 설명변수: %s / AV 기울기=전체 계수 %.6f",paste(effect()$controlled,collapse="+"),effect()$coefficient))
  output$effect_trace <- renderTable({req(input$effect_row);effect()$data[as.integer(input$effect_row),]},digits=6)
  output$effect_plot <- renderPlot({
    req(input$effect_row,input$effect_kind);z<-effect();i<-as.integer(input$effect_row)
    units<-if(input$effect_variable=="Distance")"miles" else "feet"
    if(input$effect_kind=="av") {
      x<-z$data$av_x;y<-z$data$av_y;xl<-paste0(input$effect_variable," residual (",units,")");yl<-"Time residual (seconds)";ttl<-"Added-variable: both axes residualized"
    } else {x<-z$data$cpr_x;y<-z$data$cpr_y;xl<-paste0("Original ",input$effect_variable," (",units,")");yl<-"Component + residual (seconds)";ttl<-"CPR: original predictor on x"}
    plot(x,y,pch=19,col="#8B98A7",xlab=xl,ylab=yl,main=ttl);abline(0,z$coefficient,col="#2363A0",lwd=2);points(x[i],y[i],pch=19,col="#933A72",cex=1.8);text(x[i],y[i],labels=i,pos=3,col="#933A72")
  })
  output$huber_trace <- renderTable({req(input$huber_u);w10b_huber_trace(input$huber_u)},digits=6)
  output$robust_status <- renderText(paste0("Hills35행 Huber M 수렴=",w10b_robust$converged,"; df.residual=NA는 일반 OLS 추론을 그대로 적용하지 않도록 한 설계입니다."))
  output$robust_weights <- renderTable(data.frame(row=c(7,11,18),h=hatvalues(w10b_hills_fit)[c(7,11,18)],weight=w10b_robust$w[c(7,11,18)]),digits=6)
}
shinyApp(ui,server)
