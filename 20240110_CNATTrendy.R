scp CNAT-Trendy4TACC.RData dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/CNAT-Trendy

##------START Counts
cd /scratch/08717/dmflores/LarvalGE/CNAT-Trendy

idev -A IBN21018 2:00:00
conda activate OneMap
R

BiocManager::install("Trendy")

library(Trendy)

load("CNAT-Trendy4TACC.RData")

head(expr_ND)
str(expr_ND)
 num [1:8888, 1:41] 19.418 11.568 0 0.826 0 ...
 - attr(*, "dimnames")=List of 2
  ..$ : chr [1:8877] "A0A075F932" "A0A0A2JW91" "A0A0B4J1F4" "A0A0B6VQ48" ...
  ..$ : chr [1:41] "CN2-S5" "CN2-S6" "CN3-S8" "CN3-S9" ...

class(expr_ND)
[1] "matrix" "array" 

res<-trendy(Data=expr_ND,tVectIn=time,meanCut = 0, maxK = 4, minNumInSeg = 4)


res2<-results(res) 

length(res2)
[1] 6340

res.top<-topTrendy(res2) #default adjusted Rsquare cutoff is 0.5
res.top$AdjustedR2

length(res.top$AdjustedR2)
[1] 181

T<- as.data.frame(time)
time.vector=T$time 
#Howtoshufflethereplicates-together
set.seed(12) 
shuf.temp=sample(unique(time.vector)) 
print(shuf.temp) 

##Theninthepermutationcodeyou'll do: 
res.r3<-c()
for(i in 1:100){#permute100timesatleast 
    BiocParallel::register(BiocParallel::SerialParam()) 
    shuf.temp=sample(unique(time.vector)) 
    setshuff=do.call(c,lapply(shuf.temp,function(x)which(!is.na(match(time.vector,x))))) 
    use.shuff<-time.vector[setshuff] 
    seg.shuffle<-trendy(expr_ND[sample(1:length(rownames(expr_ND)),100),],#samplegeneseachtime 
    tVectIn=use.shuff,#shufflethetimevector 
    saveObject=FALSE,numTry=5) 
    
    loopres<-results(seg.shuffle) 
    res.r3<-c(res.r3,sapply(loopres,function(x)x$AdjustedR2)) 
    }

save.image(file = "CNAT-TrendyResults.RData")


#HistogramofallR^2 
hist(res.r3,ylim=c(0,1000),xlim=c(0,1),xlab=expression(paste("AdjustedR"^"2"))) 
#Sayyouwanttousethevaluesuch thatlessthan1%ofpermutationsreach: 
sort(res.r3,decreasing=TRUE)[round(.01 * length(res.r3))] 
#Sayyouwanttousethevaluesuch thatlessthan5%ofpermutationsreach: 
sort(res.r3,decreasing=TRUE)[round(.05 * length(res.r3))]

res.top<-topTrendy(res2,adjR2Cut = 0.25) 
length(res.top$AdjustedR2)

save.image(file = "CNAT-TrendyResults.RData")

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/CNAT-Trendy/CNAT-TrendyResults.RData .
