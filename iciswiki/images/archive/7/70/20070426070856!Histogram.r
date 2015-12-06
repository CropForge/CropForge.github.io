############################################################################################
### This code is a modification from code obtained from Dr. Thomas Metz.
### This code is to create frequency histogram for each study or study by attribute.
### Data are obtained from cross-tabulation query in Access - range as columns,
### study or study by attribute as rows, and frequency as values.
### x     = object taken from Access query
### file  = path and name of pdf output file (eg. "D:/Wheat_WPA/graph.pdf")
### xlab  = label for x axes (eg. "SR(%)")
### ylab  = label for y axes (eg. "Frequency")
### mfrow = number of graph in 1 page (eg. c(2,2) --> 4 graph in 1 page (2x2))
### dcol  = the first column number where data are stored
### lcol  = column number where label are stored
############################################################################################

histo.each<-function(x,file,xlab,ylab,mfrow,dcol,lcol)
{
 pdf(file=file)                ## open pdf connection
	op<-par(mfrow=mfrow,pty="m") ## determine number of graphs in 1 page
	n<-ncol(x)  
	y<-subset(x,select=c(dcol:n))   ## select data
	z<-as.data.frame(t(y))          ## transpose data
	label<-as.vector(x[,lcol])      ## create label
	for (i in 1:ncol(z))
  {
		data=subset(z,select=c(i))    ## subset data for each column
		plot (data[,1] ~ row.names(z),  ## plot data
		type="h",
		col="red",
		ylim=c(0,1),
		main=paste(label[i]),         ## using label as graph title
		xlab=xlab, 
		ylab=ylab,
		lab=c(15,10,5),
		las=3 )
  }
  dev.off()                      ## close connection
}



##########################################################################################
### This code is to plot frequency graph for all ESWYT
### data = data from Access query - contains column for range and frequency
### file = path and name for pdf output file (eg. "D:/Wheat_WPA/graph.pdf")
### title = graph title
### xlab = x axis label
### ylab = y axis label
### fcol = column contains frequency data
### dcol = column contains range
##########################################################################################

histo.all<-function(data,file,title,xlab,ylab,fcol,rcol)
{
 pdf(file=file)                    ## open pdf connection
 plot (data[,fcol] ~ data[,rcol],  ## plot data
       type="h",
       col="red",
       main=title,
       ylim=c(0,1),
	     xlab=xlab,
       ylab=ylab,
	     lab=c(15,10,5),
	     las=3 )
 dev.off()                         ## close connection
}
