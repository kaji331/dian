library(methods) # 使用Rscript需要，R CMD不需要 for XLConnect
library(pipeR)
library(XLConnect)
load("exInfo/temp.rda")

s <- readLines("exInfo/source.csv")
p <- readLines("exInfo/definition.csv")
d <- readLines("exInfo/drug.csv")

id <- Extract[,6]

data <- data.frame(Reference=rep("",length(id)),Description=rep("",length(id)),
				   DrugResponse=rep("",length(id)))
for (i in 1:ncol(data))
	data[,i] <- as.character(data[,i])
data[id != ".",] <- cbind(s,p,d)

Extract <- cbind(Extract,data)
writeWorksheetToFile(filename,data=Extract,sheet="Sheet1",startRow=1,startCol=1)
