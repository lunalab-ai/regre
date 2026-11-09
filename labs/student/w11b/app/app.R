# W11B: edit the real model and calculation functions, then Run.
library(shiny)
paths <- c(file.path("..","data"),"data")
found <- paths[file.exists(file.path(paths,"indicator-applications-w11b.R"))]
if(!length(found)) stop("Keep the W11B data folder beside the app.")
data_dir <- found[1]
source(file.path(data_dir,"categorical-trace-w11b.R"),encoding="UTF-8")
source(file.path(data_dir,"indicator-applications-w11b.R"),encoding="UTF-8")
ski_raw <- read.csv(file.path(data_dir,"ski-sales-w11b.csv"))
edu_raw <- read.csv(file.path(data_dir,"education-w11b.csv"))

# L06_EDIT: change * to + in YOUR COPY. This actual function is passed into fitting.
student_formula <- function() {
  Y ~ (X1 + X2 + X3) * YearGroup
}

# The next definitions are extracted byte-for-byte from the shared src module.
# They are actual editable calculation functions, not display-only snippets.

cat_fit_trace <- function(fit) {
  frame <- cat_check_fit(fit)
  design <- model.matrix(fit)
  observed <- model.response(frame)
  beta <- qr.coef(qr(design),observed)
  fitted <- drop(design %*% beta)
  residual <- observed-fitted
  squared <- residual^2
  rows <- data.frame(source_row=rownames(design),observed=unname(observed),
    fitted=unname(fitted),residual=unname(residual),squared=unname(squared),
    cumulative=cumsum(unname(squared)),row.names=NULL)
  list(design=design,coefficients=beta,rows=rows,
    SSE=sum(squared),n=nrow(design),k=ncol(design),df=df.residual(fit))
}

cat_nested_trace <- function(reduced, full, tolerance=1e-9) {
  checked <- cat_check_pair(reduced,full,tolerance)
  SSE_reduced <- sum(residuals(reduced)^2)
  SSE_full <- sum(residuals(full)^2)
  if (SSE_full<=0 ||
      SSE_reduced<SSE_full-tolerance*max(1,SSE_reduced))
    stop("F needs positive full-model residual variance and a valid nested SSE.")
  q <- checked$q
  df_full <- checked$df_full
  # A tiny negative difference can only be numerical roundoff for nested OLS.
  increase <- max(0,SSE_reduced-SSE_full)
  F <- (increase/q)/(SSE_full/df_full)
  data.frame(n=checked$n,k_reduced=reduced$rank,k_full=full$rank,q=q,
    df_full=df_full,SSE_reduced=SSE_reduced,SSE_full=SSE_full,
    F=F,p=pf(F,q,df_full,lower.tail=FALSE))
}


# mode + actual edited function -> real fits, residual table and nested comparison.
# No source() here: editing the function above is retained by every callback.
make_result <- function(mode,c_shift=0,quarter_ref=4L,year_ref=1975L,formula_fn=student_formula) {
  if(mode=="mean") {
    d <- data.frame(source_row=1:9,y=c(4,5,6,6,7,8,8,9,10),Group=factor(rep(c("A","B","C"),each=3),levels=c("C","A","B")))
    d$y[d$Group=="C"] <- d$y[d$Group=="C"]+c_shift
    contrasts(d$Group) <- contr.treatment(levels(d$Group),base=1)
    r <- lm(y~1,d); f <- lm(y~Group,d)
  } else if(mode=="season") {
    d <- ia_quarter_prepare(ski_raw,quarter_ref)
    r <- lm(Sales~PDI,d); f <- lm(Sales~PDI+Quarter,d)
  } else if(mode=="year") {
    d <- ia_year_prepare(edu_raw,year_ref)
    m <- ia_year_models(d,formula_fn);r <- m$common; f <- m$full
  } else stop("Choose mean, season or year.")
  trace <- cat_fit_trace(f)
  list(mode=mode,data=d,reduced=r,fit=f,trace=trace,test=cat_nested_trace(r,f))
}

# The downloadable script contains the current actual function and current data.
# It works in a clean base-R session and writes the same complete trace CSV.
write_replay <- function(result,file,formula_fn=student_formula) {
  code <- c("# W11B saved calculation: source units and current edited function/data.")
  for(fn in c("cat_check_fit","cat_check_pair","cat_fit_trace","cat_nested_trace"))
    code <- c(code,paste0(fn," <- ",paste(deparse(get(fn)),collapse="\n")))
  code <- c(code,"data <- ",capture.output(dput(result$data)))
  formula_code <- if(result$mode=="year") deparse(formula_fn) else
    c("function() {",paste(deparse(formula(result$fit)),collapse=" "),"}")
  code <- c(code,paste0("student_formula <- ",paste(formula_code,collapse="\n")),
    paste0("reduced <- lm(",paste(deparse(formula(result$reduced)),collapse=" "),",data,na.action=na.fail)"),
    "full <- lm(student_formula(),data,na.action=na.fail)",
    "result <- cat_nested_trace(reduced,full)","print(result,digits=12)",
    "trace <- cat_fit_trace(full)$rows","write.csv(trace,'w11b-replayed.csv',row.names=FALSE)")
  writeLines(code,file,useBytes=TRUE)
}
course_download <- function(...) {
  tag <- downloadButton(...)
  if(grepl("emscripten",R.version$platform,fixed=TRUE)) tag$attribs$download <- NULL
  tag
}
ui <- fluidPage(
  tags$head(tags$style(HTML("body{font-size:16px}.trace-scroll{overflow-x:auto}.trace-scroll table{min-width:600px}@media(max-width:700px){.col-sm-4,.col-sm-8{width:100%}}"))),
  titlePanel("W11B · 평균·계절·시간 안정성 실험실"),
  p("예상 → 한 행 계산 → 실제 함수 수정 → 표·그림 → CSV/R 저장 → 새 세션 재실행. 같은 행·가정·관측 범위를 함께 읽습니다."),
  tabsetPanel(id="application",selected="mean",
    tabPanel("1. 집단 평균",value="mean",
      fluidRow(column(4,sliderInput("c_shift","자체 예의 C집단 모든 값에 더할 수",0,3,0,step=1),
        p("A=4,5,6 / B=6,7,8 / C=8,9,10. 교재 자료와 구별한 자체9개 예입니다."),
        course_download("mean_csv","현재9행 CSV"),course_download("mean_r","현재 계산 R")),
        column(8,tableOutput("mean_test"),plotOutput("mean_plot",height="340px"))),
      p("C의 모든 값을 옮기면 집단내 오차와 집단간 변동이 어떻게 달라질지 먼저 예상하세요. 전체 검정이 유의해도 모든 쌍이 다른 것은 아닙니다.")),
    tabPanel("2. 분기 계절성",value="season",
      fluidRow(column(4,selectInput("quarter_ref","분기 기준",choices=1:4,selected=4),
        p("공식 Ski40행. Sales/PDI는 원척도입니다. 기준 변경은 같은 모형의 재표현입니다. 시간 오차 독립성은 별도 확인합니다."),
        course_download("season_csv","현재40행 CSV"),course_download("season_r","현재 계산 R")),
        column(8,textOutput("season_formula"),tableOutput("season_test"),plotOutput("season_plot",height="340px")))),
    tabPanel("3. 시간적 안정성",value="year",
      fluidRow(column(4,selectInput("year_ref","연도 기준",choices=c(1975,1960,1970),selected=1975),
        p("L06: 편집기 상단 student_formula의 *를 +로 바꾼 사본을 Run하세요. 실제 전달된 함수로 적합합니다."),
        textOutput("year_formula"),textOutput("year_support"),
        course_download("year_csv","현재150행 CSV"),course_download("year_r","현재 함수·자료·계산 R")),
        column(8,tableOutput("year_test"),plotOutput("year_plot",height="340px"))),
      p("같은50주 반복 관측입니다. 고전적 독립·동분산·정규오차 가정의 검정과 정책 인과효과를 구별합니다. 다운로드R은 현재 함수를 보존하며 새 R세션에서 실행하면 w11b-replayed.csv를 만듭니다.")),
    tabPanel("이전 누적 기능",value="previous",
      p("지시변수·급료·두 집단·QR 및 이전 진단 기능을 원래 주소로 유지합니다."),
      tags$a(href="https://lunalab-ai.github.io/regre/apps/w11a/edit/index.html",target="_blank","W11A까지의 누적 앱 편집기"),
      tags$iframe(src="https://lunalab-ai.github.io/regre/apps/w11a/",title="이전 누적 회귀 기능",width="100%",height="650px",loading="lazy",style="border:1px solid #ccd5df"))
  ),
  conditionalPanel(condition="input.application !== 'previous'",
    h3("현재 적합의 실제 중간값"),
    p("아래 표는 실제 사용한 열과 QR계수, 관측−적합·잔차²·누적합입니다. CSV에는 첫8행만이 아니라 모든 행이 포함됩니다."),
    div(class="trace-scroll",tableOutput("current_design")),tableOutput("current_coefficients"),
    div(class="trace-scroll",tableOutput("current_trace")))
)
server <- function(input,output,session) {
  mean_res <- reactive({req(!is.null(input$c_shift));make_result("mean",c_shift=input$c_shift,formula_fn=student_formula)})
  season_res <- reactive({req(input$quarter_ref);make_result("season",quarter_ref=as.integer(input$quarter_ref),formula_fn=student_formula)})
  year_res <- reactive({req(input$year_ref);make_result("year",year_ref=as.integer(input$year_ref),formula_fn=student_formula)})
  current <- reactive({req(input$application);switch(input$application,mean=mean_res(),season=season_res(),year=year_res(),previous=mean_res())})
  output$mean_test <- renderTable(mean_res()$test,digits=7)
  output$season_test <- renderTable(season_res()$test,digits=7)
  output$year_test <- renderTable(year_res()$test,digits=7)
  describe <- function(z) sprintf("%s · n=%d · k=%d · df=%d",paste(deparse(formula(z$fit)),collapse=" "),nobs(z$fit),z$fit$rank,df.residual(z$fit))
  output$season_formula <- renderText(describe(season_res()))
  output$year_formula <- renderText(describe(year_res()))
  output$year_support <- renderText("X1관측범위:1960[1053,2817],1970[2081,4256],1975[3448,5889]. 세 연도 공통범위 없음.")
  output$mean_plot <- renderPlot({
    z<-mean_res();d<-z$data;plot(as.numeric(d$Group),d$y,pch=19,col=as.integer(d$Group),xaxt="n",xlab="Group (C baseline)",ylab="y (own example)",main="Observed values and fitted group means")
    axis(1,at=1:3,labels=levels(d$Group));points(1:3,tapply(fitted(z$fit),d$Group,mean),pch=18,cex=2,col="blue")
  })
  output$season_plot <- renderPlot({
    z<-season_res();d<-z$data;plot(d$PDI,d$Sales,col=d$QuarterNumber,pch=d$QuarterNumber,xlab="PDI (original scale)",ylab="Sales (original scale)",main="Observed points; quarter-specific fitted means")
    for(q in 1:4){xx<-seq(min(d$PDI[d$QuarterNumber==q]),max(d$PDI[d$QuarterNumber==q]),length.out=30);nd<-data.frame(PDI=xx,Quarter=factor(q,levels=levels(d$Quarter)));lines(xx,predict(z$fit,nd),col=q,lty=q,lwd=2)}
  })
  output$year_plot <- renderPlot({
    z<-year_res();plot(fitted(z$fit),z$data$Y,col=as.integer(z$data$YearGroup),pch=19,xlab="Fitted education Y (original scale)",ylab="Observed education Y (original scale)",main=paste("Current actual function: k =",z$fit$rank));abline(0,1,lty=2)
    legend("topleft",legend=levels(z$data$YearGroup),col=1:3,pch=19,bty="n")
  })
  output$current_design <- renderTable(head(current()$trace$design,6),rownames=TRUE,digits=4)
  output$current_coefficients <- renderTable(data.frame(term=names(current()$trace$coefficients),coefficient=unname(current()$trace$coefficients)),digits=7)
  output$current_trace <- renderTable(head(current()$trace$rows,8),digits=6)
  for(mode in c("mean","season","year")) local({
    mode0<-mode
    result<-function()switch(mode0,mean=mean_res(),season=season_res(),year=year_res())
    output[[paste0(mode0,"_csv")]]<-downloadHandler(filename=function()paste0("w11b-",mode0,"-trace.csv"),content=function(file)write.csv(result()$trace$rows,file,row.names=FALSE))
    output[[paste0(mode0,"_r")]]<-downloadHandler(filename=function()paste0("w11b-",mode0,"-replay.R"),content=function(file)write_replay(result(),file,student_formula))
  })
}
shinyApp(ui,server)
