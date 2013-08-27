library(ffbase)
.vimplemented # notice that character is not supported, use factor instead


## generate synthetic data
id <- 1:1000
d <- strftime(seq(Sys.Date(), by='-1 day', length=30), format='%Y/%m/%d')
h24 <- c(0:23)
score <- rnorm(15000, mean=60, sd=15)

options(warn=-1)
dat <- cbind(id=id, d=d, h24=h24, score=score)
options(warn=0)


dat <- as.data.frame(dat, stringsAsFactors=TRUE)
dat$h24 <- as.integer(dat$h24)
dat$score <- as.numeric(dat$score)

str(dat)

dat.ff <- as.ffdf(dat)
save.ffdf(dat.ff, dir='data/')