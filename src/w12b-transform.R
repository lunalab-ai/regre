# Shared W12B data, model summaries and plots.
positive_axis <- function(x) {
  if (!is.numeric(x) || !length(x) || any(!is.finite(x)) || any(x <= 0)) {
    stop("This axis requires finite, strictly positive observations.")
  }
  invisible(x)
}

make_w12b_data <- function(kind) {
  set.seed(switch(kind, count=447L, factory=451L, animals=453L, stop("Unknown data kind.")))
  if (kind=="count") {
    N <- rep(c(.02,.05,.08,.12,.20,.30,.42),each=20)
    frame <- data.frame(N=N, Y=rpois(length(N),lambda=110*N))
  } else if (kind=="factory") {
    X <- rep(seq(250,1650,by=50),each=2)
    offset <- rep(seq(-1,.9,length.out=29),each=2)
    Y <- pmax(1,round(exp(4.5 + .9*offset - .34*offset^2) + .016*X*rnorm(length(X))))
    frame <- data.frame(X=X,Y=Y)
  } else {
    BodyWeight <- exp(seq(-3,8,length.out=25))
    BrainWeight <- exp(1.8 + .73*log(BodyWeight)+rnorm(length(BodyWeight),sd=.32))
    frame <- data.frame(Name=c(sprintf("Synthetic %02d",seq_along(BodyWeight)), "Synthetic A","Synthetic B","Synthetic C"),
                        BodyWeight=c(BodyWeight,9000,11500,70000),
                        BrainWeight=c(BrainWeight,52,70,151))
  }
  attr(frame,"mode") <- "Synthetic / classroom"
  frame
}

read_w12b_data <- function(kind, mode="official") {
  if (mode=="synthetic") return(make_w12b_data(kind))
  if (!identical(mode,"official")) stop("Choose official or synthetic.")
  definition <- switch(kind, count=list("Injury.txt",9L,c("Y","N")),
                       factory=list("Supervised.Workers.txt",27L,c("X","Y")),
                       animals=list("Animals.txt",28L,c("Name","BrainWeight","BodyWeight")),
                       stop("Unknown data kind."))
  file <- definition[[1]]
  cache <- file.path(tempdir(), paste0("w12b-official-",file))
  validate <- function(path) {
    d <- read.delim(path,check.names=FALSE,stringsAsFactors=FALSE)
    stopifnot(identical(names(d),definition[[3]]),nrow(d)==definition[[2]])
    for (col in names(d)[names(d)!="Name"]) positive_axis(d[[col]])
    if (kind=="count") stopifnot(all(d$Y==round(d$Y)),all(d$N<=1))
    if (kind=="animals") stopifnot(!anyDuplicated(d$Name),all(nzchar(d$Name)))
    attr(d,"mode") <- "Official / Hadi RABE6"
    d
  }
  original <- file.path("source_materials","textbook_data","rabe6",file)
  if (file.exists(original)) return(validate(original))
  if (file.exists(cache)) {
    d <- tryCatch(validate(cache),error=function(e) NULL)
    if (!is.null(d)) return(d)
  }
  url <- paste0("https://www1.aucegypt.edu/faculty/hadi/RABE6/Data6/",file)
  tryCatch({
    work <- tempfile("w12b-download-")
    on.exit(unlink(work),add=TRUE)
    old <- options(timeout=20)
    on.exit(options(old),add=TRUE)
    if (download.file(url,work,mode="wb",quiet=TRUE)!=0L) stop("Download failed.")
    d <- validate(work)
    if (!file.copy(work,cache,overwrite=TRUE)) stop("Could not cache the verified dataset.")
    d
  },error=function(e) {
    message("Official file unavailable (",conditionMessage(e),"). Using labeled synthetic data.")
    make_w12b_data(kind)
  })
}

basis_w12b <- function(x, lambda) {
  positive_axis(x)
  if (length(lambda)!=1L || !is.finite(lambda)) stop("Use a finite lambda.")
  if (lambda==0) log(x) else x^lambda
}

summarize_w12b_fit <- function(d, model, fitted_y=fitted(model)) {
  e <- d$Y-as.numeric(fitted_y)
  w <- weights(model)
  if (is.null(w)) w <- rep(1,nrow(d))
  data.frame(mode=attr(d,"mode"), row=seq_len(nrow(d)), X=d$X, observed=d$Y,
             fitted_y=as.numeric(fitted_y), residual=e, weight=w,
             weighted_residual=sqrt(w)*e, weighted_squared_error=w*e^2,
             fit_standardized=as.numeric(rstandard(model)))
}

w12b_rmse <- function(y, pred) sqrt(mean((y-pred)^2))

plot_w12b_residual <- function(x,e,label,ylab="Standardized residual",ids=integer(0)) {
  plot(x,e,pch=19,cex=.8,col="#1b699e",xlab="Predictor",ylab=ylab,main=label)
  abline(h=0,lty=2,col="#a64d2b")
  if (length(ids)) text(x[ids],e[ids],ids,pos=3,col="#a64d2b",cex=.8)
}

plot_w12b_comparison <- function(d, base, current) {
  idx <- order(d$X)
  plot(d$X,d$Y,pch=19,cex=.8,col="#1b4265",xlab="X",ylab="Original Y",main=attr(d,"mode"))
  lines(d$X[idx],base[idx],lty=2,lwd=2,col="#1b699e")
  lines(d$X[idx],current[idx],lwd=2,col="#a64d2b")
  legend("topleft",c("OLS","Current fit"),lty=c(2,1),lwd=2,
         col=c("#1b699e","#a64d2b"),bty="n",cex=.82)
}
