##############################################################################
## This command is to create present absent table of genotype by year and genotype
## by location. The genotype will be grouped based on their first occurrs.
## data = from Access query
## file = input file
## col1 = column number for genotype
## col2 = column number for grouping (ESWYT)
## range = range of column data
############################################################################

group.tab=function(data,file,col1,col2,col.order=F,freq=NULL,range)
{
unq=unique(data[,col1])
group=vector("numeric",length(unq))
for(i in 1:length(unq))
 {
  group[i]=data[match(unq[i],data[,col1]),col2]
 }
list=cbind(group,unq)
list=list[order(list[,2],decreasing=F),]
dat1=subset(data,select=c(range))
gy1=unique(dat1)
y = table(gy1[,1],gy1[,2])
y1 = cbind(list,y)
y2 = y1[order(y1[,1],y1[,2],decreasing=F),]
ydat=subset(y2,select=c(3:ncol(y2)))
if(col.order==F)
 {
  freq=NULL
  ydat=xdat
 }
if(col.order==T)
 {
  freq=freq
  y3=t(ydat)
  y4=cbind(y3,freq)
  ysort=y4[order(y4[,ncol(y4)],decreasing=T),]
  ysort=subset(ysort,select=c(1:ncol(y3)))
  xdat=t(ysort)
 }
write.table(xdat,file,row.names=T,col.names=T, quote=F)
}

##############################################################################
## This command is to create heatmap graph based on previous table (this code
## is a modification from heatmap code).
## dfile = data file (from previous script)
## ofile = output file
## xlab = x axis label
## ylab = y  axis label
## title = graph title
############################################################################

group.plot=function(dfile,ofile,xlab,ylab,title,x.axis=T,y.axis=T)
{
pdf(ofile)
op=par(pin=c(4,4))
hc=heat.colors(2, alpha = 1)
hc1=vector("character",2)
hc1[1]=hc[2]
hc1[2]=hc[1]
x=read.table(dfile,header=T)
x1=x[nrow(x):1,]
x1=as.matrix(x1)
nc=ncol(x1)
nr=nrow(x1)
cexCol= cexCol = 0.2 + 1/log10(nc)
cexRow = 0.3+ 1/log10(nr)
image(1:nc, 1:nr, t(x1), axes=F,col=hc1,xlim = 0.5 + c(0, nc), ylim = 0.5 + 
        c(0, nr), xlab = xlab, ylab = ylab, main=title)
if(x.axis==T)
{
labCol=row.names(t(x1))
axis(1, 1:nc, labels = labCol, las = 2, line = -0.5, tick = 0, 
        cex.axis = cexCol)
}
if(y.axis==T)
{
labRow=row.names(x1)
axis(2, 1:nr, labels = labRow, las = 1, line = -0.5, tick = 0, 
        cex.axis = cexRow)
}
dev.off()
}











