library(pipeR)
argv <- commandArgs(TRUE)
vcf <- read.table(argv[1],sep="\t")
vcf[,8]=""
filename <- sub("(.*).vcf","\\1",argv[1]) %>>% paste("rmInfo",sep="_") %>>% paste("vcf",sep=".") %>>% (paste("rmInfo/",.,sep=""))
write.table(vcf,file=filename,sep="\t",quote=F,row.names=F,col.names=F)
