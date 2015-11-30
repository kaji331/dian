library(pipeR)

writeBed <- function(tissue) {
	gene_name <- paste("results/",tissue,"_genes.csv",sep="")
	pos_name <- paste("results/",tissue,"_pos.csv",sep="")
	gene <- read.csv(gene_name)
	pos <- read.csv(pos_name)
	write.table(cbind(pos[,2:4],gene[,2]),file=paste("results/",tissue,".bed",sep=""),quote=F,sep="\t",row.names=F,col.names=F)
}

writeBed("breast")
writeBed("lung")
writeBed("liver")
writeBed("colorect")
writeBed("gastric")
