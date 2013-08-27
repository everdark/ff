### Kyle Chung <alienatio@pixnet.net>
### Operation on ff object: aggregation (absorption/group-by)



################################################################################
####                        set up working environment                      ####
################################################################################
library(ffbase)

## load ff object
# be aware that there is no asignment for the loaded ff object
load.ffdf(dir='data/')
ls()


################################################################################
####                        aggregation via ffdfdply                        ####
################################################################################
## the tricky part: split keys are necessary, 
## but data will not be splitted by the keys (but by memory availability)
## consequently, a user-defined aggregator must deal with the splitting

# for group var: id, d, h24
# firstly, generate split keys on the targeted ffdf
dat.ff$skey <- ikey(dat.ff[c('id', 'd', 'h24')])
# keys must be of type integer
dat.ff$skey <- with(dat.ff, as.integer(skey))
# aggregator must be user-defined with return value data.frame
absorb <- function(x) {
    x <- aggregate(data=x, score ~ id + d + h24, FUN=sum)
    colnames(x) <- c('id', 'd', 'h24', 'sum')
    x
}
aggregated <- ffdfdply(dat.ff, split=dat.ff$skey, FUN=absorb)

# check 
c1 <- absorb(as.data.frame(dat.ff))
c2 <- as.data.frame(aggregated)
identical(c1, c2)


################################################################################
####                        merge                                           ####
################################################################################
# merge aggregate results back to the original ffdf
merged.ff <- merge(dat.ff, aggregated, 
                   by=intersect(names(dat.ff), names(aggregated)))
merged.ff$skey <- NULL # drop split keys
dim(merged.ff)


################################################################################
####                        filter                                          ####
################################################################################
## numerical filtering
# use ffwhich(), the resulting index itself is ff vector
index <- ffwhich(merged.ff, sum > 50000)
# that vector can be used for indexing
filtered.ff <- merged.ff[index,]
dim(filtered.ff)


## datetime filtering: a string matching solution
# prepare covering date list
covering_dates <- strftime(seq(Sys.Date(), by='-1 day', length=30), 
                           format='%Y/%m/%d')    
matched.ff <- merged.ff[ffwhich(merged.ff, d %in% covering_dates),]
# check
sum(!unique(matched.ff$d[]) %in% covering_dates)

