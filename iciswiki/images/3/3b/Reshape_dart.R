library(reshape);

####################################################################
# Tab-delimited data have been downloaded from the virtualmendel
# server and are locally accessible
#
# This is how the data look like for this example:
#
# GID	MD	PD	DART CLONE	INVESTIGATOR ID	ENTRY ...
# 4057142	1835	1934	119458	-4	F12	CIMMYT ...
# 4057142	1193	842	115719	-4	F12	CIMMYT ...
# 4057142	1870	1969	115694	-4	F12	CIMMYT ...
# ...
####################################################################
dart = read.table("DW06.txt", header = TRUE, sep="\t");

#########################################################################
# recode MV_STATE to a new numeric variable (state)
# + -> 1
# - -> 0
# * -> NA
#########################################################################
dart$state[dart$MV.STATE == "*"] = NA;
dart$state[dart$MV.STATE == "-"] = 0;
dart$state[dart$MV.STATE == "+"] = 1;

############################################################
# create a subset of the data by extracting only the columns
# ENTRY, MV.NAMe, state
############################################################
newdart = dart[,c("ENTRY", "MV.NAME","state")];

########################################################################
# Rename columns as the melt() function of the reshape library would do
# so that we can use the cast() function with MV.NAMEs as columns,
# ENTRYs as rows, and state values in the cells.
#
# The reshaped data look like this:
# entry TC117430 TC117438 TC117439 TC117493 wPt-0008 ...
#   F12        1        0        0        1        0 ...
# ...
########################################################################
colnames(newdart) = c("entry","variable","value");
paralleldart = cast(newdart, entry ~ variable); 
