###############################################################################
### This code is to perform boxplot on data for each study or study by attributes
### x     = data object obtain from Access query
### list  = list of factor in data (eg. 01ESWYT_LID=15000)
### file  = name of output file
### mfrow = number of graph/page (eg. c(3,3)-->produce 9 graphs in 1 page)
### lcol  = column number where factor names are stored
### dcol  = column number wehere data are stored
################################################################################

box.plot.each<-function(x,list,file,mfrow,lcol,dcol,ylab)
{
	pdf(file=file)                   ## open pdf connection
	op<-par(mfrow=mfrow,pty="s")     ## determine number of graphs in 1 page
	for(i in 1:nrow(list))
	{
	  data=subset(x,x[,lcol]==list[i,1]) ## subset data based on label
	  boxplot(data[,dcol],main=paste(list[i,1]),ylab=ylab)  ## plot data
	}
	dev.off()                    ## close connection
}

###############################################################################
### This code is to perform boxplot on data accross all study
### x     = data object obtain from Access query
### file  = path and name of pdf output file
### dcol  = column number where data are stored
### title = title for graph
### ylab  = label for y-axis
################################################################################

box.plot.all<-function(x,file,dcol,title,ylab)
{
	pdf(file=file)
	boxplot(x[,dcol],main=title,ylab=ylab)
	dev.off()
}
