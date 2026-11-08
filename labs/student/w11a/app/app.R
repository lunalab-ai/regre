# W11A cumulative extension. Base R calculations are visible in the lesson body.
library(shiny)
paths <- c(file.path("..","data"),"data")
found <- paths[file.exists(file.path(paths,"categorical-trace-w11a.R"))]
if(!length(found)) stop("Keep the W11A data directory beside this app.")
data_dir <- found[1]
source(file.path(data_dir,"diagnostics-learning-w11a.R"),encoding="UTF-8")
source(file.path(data_dir,"categorical-trace-w11a.R"),encoding="UTF-8")
salary <- read.csv(file.path(data_dir,"salary-survey-w11a.csv"))
pre <- read.csv(file.path(data_dir,"preemployment-w11a.csv"))
models <- cat_two_group_models(pre)

# L06_EDIT: change * to + in your COPY, then Run and inspect all actual outputs.
student_formula <- function() JPERF ~ TEST * RACE

course_download <- function(...) {
  tag <- downloadButton(...)
  if(grepl("emscripten",R.version$platform,fixed=TRUE)) tag$attribs$download <- NULL
  tag
}
ui <- fluidPage(
  tags$head(tags$style(HTML("body{font-size:16px}.trace-scroll{overflow-x:auto}.trace-scroll table{min-width:620px}@media(max-width:700px){.col-sm-4,.col-sm-8{width:100%}}"))),
  titlePanel("W11A · 식에서 계산까지 보는 회귀 실험실"),
  p("예상과 이유 → 작은 계산 → 실제 함수 → 표·그림 → 조건 변경 → 한 문장 설명. 원자료의 행과 코딩을 보존합니다."),
  tabsetPanel(
    tabPanel("1. 한 사람의 급료 예측",
      fluidRow(column(4,
        selectInput("education","학력",c("고졸"=1,"학사"=2,"대학원"=3),selected=2),
        radioButtons("management","관리직",c("비관리직"=0,"관리직"=1),selected=1,inline=TRUE),
        sliderInput("experience","경력 (년)",min=0,max=20,value=5,step=1),
        checkboxInput("interaction","학력×관리직 곱항 포함",TRUE),
        selectInput("reference","학력의 기준범주",c("대학원"=3,"고졸"=1,"학사"=2),selected=3),
        textOutput("salary_summary"),textOutput("salary_support"),
        course_download("salary_csv","현재 기여분 CSV")),
      column(8,div(class="trace-scroll",tableOutput("salary_trace")),
        plotOutput("salary_plot",height="340px"),tableOutput("salary_gaps"))),
      p("표는 실제 cat_row_trace의 value×coefficient입니다. 합계는 같은 조건의 평균 연봉 예측입니다. 기준만 바꾸면 예측은 같고, 평균모형을 바꾸면 달라질 수 있습니다.")),
    tabPanel("2. 두 집단의 식과 검정",
      fluidRow(column(4,
        selectInput("model","평균모형",c("내 코드 모형"="student","M0 · 하나의 선"="M0","MI · 평행선"="MI","MS · 같은 절편"="MS","MF · 둘 다 허용"="MF")),
        sliderInput("test_score","TEST (원자료 척도)",min=0,max=2.7,value=1.5,step=.1),
        textOutput("group_formula"),textOutput("group_support"),
        course_download("group_csv","두 집단 평균·차이 CSV")),
      column(8,tableOutput("group_lines"),tableOutput("group_predictions"),
        plotOutput("group_plot",height="380px"),tableOutput("group_comparison"))),
      h4("L06 · 실제 모형 함수 수정"),
      p("편집기 상단 student_formula()의 TEST * RACE를 TEST + RACE로 바꾼 사본을 Run 하세요. 내 코드 모형을 선택하고 입력을 바꿔 두 기울기·집단 차이·SSE·F가 함께 어떻게 바뀌는지 확인합니다. 행 수는20으로 유지됩니다. 수정 R과 CSV를 저장하고 R 세션을 재시작하여 같은 결과를 확인하세요."),
      p("이 탭은 교재의 역사적 Preemployment20행을 사용합니다. 원래 RACE0/1 코딩을 보존하며 인과 효과나 개별 채용 결정을 추정하지 않습니다. M0와 같은 모형을 선택하면 추가 계수가 없어 부분F가 적용되지 않습니다.")),
    tabPanel("3. QR·잔차·SSE를 펼쳐 보기",
      p("선택한 두 집단 모형의 실제 설계행렬과 QR계수, 관측−적합, 잔차²·누적합을 확인합니다. 표시된 열은 계산에 실제로 사용됩니다."),
      div(class="trace-scroll",tableOutput("design_trace")),tableOutput("qr_coefficients"),
      div(class="trace-scroll",tableOutput("residual_trace"))),
    tabPanel("이전 누적 기능",
      p("W10B의 영향력·AV/CPR·Huber와 첫 회귀 예측 기능을 원래 링크로 이어 사용합니다. 이전 배포와 자료를 보존한 누적 기능이며 인터넷 연결이 필요합니다."),
      tags$a(href="https://lunalab-ai.github.io/regre/apps/w10b/edit/index.html",target="_blank","이전 누적 실험실 편집기"),
      tags$iframe(src="https://lunalab-ai.github.io/regre/apps/w10b/",title="W10B까지의 누적 회귀 기능",width="100%",height="700px",loading="lazy",style="border:1px solid #ccd5df"))
  )
)
server <- function(input,output,session) {
  salary_model <- reactive({req(input$reference);salary_fit(salary,isTRUE(input$interaction),reference=as.integer(input$reference))})
  salary_person <- reactive({
    req(input$education,input$management,!is.null(input$experience))
    fit <- salary_model()
    data.frame(X=input$experience,Education=factor(c("HighSchool","Bachelor","Graduate")[as.integer(input$education)],levels=fit$xlevels$Education),M=as.integer(input$management))
  })
  salary_trace <- reactive(cat_row_trace(salary_model(),salary_person()))
  output$salary_trace <- renderTable(salary_trace(),digits=4)
  output$salary_summary <- renderText(sprintf("n=46 · k=%d · df=%d · 평균 예측 %.3f 달러/년",salary_model()$rank,df.residual(salary_model()),sum(salary_trace()$contribution)))
  output$salary_support <- renderText({
    z<-salary[ salary$E==as.integer(input$education)&salary$M==as.integer(input$management),"X"]
    if(input$experience<min(z)||input$experience>max(z)) sprintf("해당 집단 관측 경력%d–%d년 밖: 외삽입니다.",min(z),max(z)) else sprintf("해당 집단 관측 경력%d–%d년 안입니다.",min(z),max(z))
  })
  output$salary_gaps <- renderTable(salary_group_gaps(salary_model(),input$experience),digits=3)
  output$salary_plot <- renderPlot({
    z<-salary_trace();barplot(z$contribution,names.arg=z$term,las=2,cex.names=.65,col="#2363A0",ylab="Contribution (USD/year)",main="Actual term contributions; sum = group mean")
  })
  output$salary_csv <- downloadHandler(filename=function()"w11a-salary-contributions.csv",content=function(file)write.csv(salary_trace(),file,row.names=FALSE))
  selected_fit <- reactive({req(input$model);if(input$model=="student") lm(student_formula(),pre,na.action=na.fail) else models[[input$model]]})
  line_table <- reactive(cat_group_lines(selected_fit()))
  group_predictions <- reactive({
    req(!is.null(input$test_score));z<-line_table();value<-z$intercept+z$slope*input$test_score
    data.frame(Z=0:1,TEST=input$test_score,mean_prediction=value,gap_1_minus_0=rep(value[2]-value[1],2))
  })
  output$group_formula <- renderText(sprintf("%s · n=%d · k=%d · df=%d",paste(deparse(formula(selected_fit())),collapse=" "),nobs(selected_fit()),selected_fit()$rank,df.residual(selected_fit())))
  output$group_lines <- renderTable(line_table(),digits=6)
  output$group_predictions <- renderTable(group_predictions(),digits=6)
  output$group_support <- renderText({
    outside<-vapply(0:1,function(z){rg<-range(pre$TEST[pre$RACE==z]);input$test_score<rg[1]||input$test_score>rg[2]},logical(1))
    if(any(outside)) paste("관측 TEST 범위 밖인 집단:",paste((0:1)[outside],collapse=", ")) else "두 집단의 관측 TEST 범위 안입니다."
  })
  output$group_plot <- renderPlot({
    z<-line_table();plot(pre$TEST,pre$JPERF,pch=ifelse(pre$RACE==0,16,17),col=ifelse(pre$RACE==0,"steelblue","darkorange"),xlim=c(0,2.7),ylim=c(0,10),xlab="TEST (original scale)",ylab="JPERF (original scale)",main="Same20 rows; model changed by the actual function")
    for(i in 1:2)abline(z$intercept[i],z$slope[i],col=c("steelblue","darkorange")[i],lwd=2,lty=i)
    points(rep(input$test_score,2),group_predictions()$mean_prediction,pch=21,bg=c("steelblue","darkorange"),cex=1.6)
  })
  comparison_table <- reactive({
    if(selected_fit()$rank==models$M0$rank) return(data.frame(status="M0: no added parameters; partial F is not applicable",SSE=deviance(selected_fit())))
    cat_nested_trace(models$M0,selected_fit())
  })
  output$group_comparison <- renderTable(comparison_table(),digits=7)
  output$group_csv <- downloadHandler(filename=function()"w11a-group-means.csv",content=function(file)write.csv(group_predictions(),file,row.names=FALSE))
  full_trace <- reactive(cat_fit_trace(selected_fit()))
  output$design_trace <- renderTable(head(full_trace()$design,6),rownames=TRUE,digits=4)
  output$qr_coefficients <- renderTable(data.frame(term=names(full_trace()$coefficients),coefficient=unname(full_trace()$coefficients)),digits=7)
  output$residual_trace <- renderTable(full_trace()$rows,digits=5)
}
shinyApp(ui,server)
