library(methods) # 使用Rscript需要，R CMD不需要 for XLConnect
library(pipeR)
library(XLConnect)
source("/home/galaxy/Downloads/clinvar_xml/clinvar_xml.R")
argv <- commandArgs(TRUE)
annotation <- read.table(argv[1],sep="\t",header=F)

# ======
ID <- as.character(annotation[,3])

r <- regexpr("AF=(.*?);",annotation[,8])
AF <- regmatches(annotation[,8],r)
AF <- sub("AF=(.*?);","\\1",AF)
AF[AF=="1"] <- "Hom"
AF[AF=="0.5"] <- "Het"

r <- regexpr("EFF=(.*?);",as.character(annotation[,8]))
EFF <- regmatches(as.character(annotation[,8]),r)
SYMBOL <- sub("EFF=(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*)","\\6",EFF)
CHANGE <- sub("EFF=(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*)","\\4",EFF)
NM_NUM <- sub("EFF=(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*)","\\9",EFF)
SENSE <- sub("EFF=(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*?)\\|(.*)","\\2",EFF)
CHANGE <- sapply(strsplit(CHANGE,"/"),function(x) rev(x)) %>>% sapply(function(x) if (length(x) == 2) paste(x[1],x[2],sep="(") %>>% paste0(")") else x) %>>% sapply(function(x) if (length(x) == 0) x <- NA else x) %>>% (paste(NM_NUM,.,sep=":")) %>>% (sapply(strsplit(.,":"),function(x) if (x[2] == "NA") x <- NA else paste(x[1],x[2],sep=":")))

r <- regexpr("clinvar(.*?)=(.*?);",as.character(annotation[,8]))
CLINSIG <- regmatches(as.character(annotation[,8]),r)
CLINSIG <- sub("clinvar(.*?)=(.*?)x3d(.*?)\\\\x3b(.*)","clinvar\\1=\\3",CLINSIG) %>>% (sub("clinvar(.*?)=(.*?)\\|(.*)","\\2",.)) %>>% (sub("clinvar(.*?)=(.*?)","\\2",.)) %>>% (sub("(.*?);","\\1",.))

r <- regexpr("DP=(.*?);",annotation[,8])
DP <- regmatches(annotation[,8],r)
DP <- sub("DP=(.*?);","\\1",DP)

r <- regexpr("AB=(.*?);",annotation[,8])
AB <- regmatches(annotation[,8],r)
AB <- sub("AB=(.*?);","\\1",AB)

r <- regexpr("SIFT_score=(.*?);",annotation[,8])
SS <- regmatches(annotation[,8],r)
SS <- sub("SIFT_score=(.*?);","\\1",SS)

r <- regexpr("SIFT_pred=(.*?);",annotation[,8])
SP <- regmatches(annotation[,8],r)
SP <- sub("SIFT_pred=(.*?);","\\1",SP)

r <- regexpr("1000g2015aug_all=(.*?);",annotation[,8])
ALL_1000 <- regmatches(annotation[,8],r)
ALL_1000 <- sub("1000g2015aug_all=(.*?);","\\1",ALL_1000)

r <- regexpr("1000g2015aug_eas=(.*?);",annotation[,8])
EAS_1000 <- regmatches(annotation[,8],r)
EAS_1000 <- sub("1000g2015aug_eas=(.*?);","\\1",EAS_1000)

rsNum <- ID
rsNum[rsNum != "."] <- sapply(strsplit(rsNum[rsNum != "."],"s"),function(x) x[2])
Des <- sapply(rsNum,function(x) refDescription(xl_sub,x))
ref <- sapply(rsNum,function(x) Url(xl_sub,x))

# ======
Extract <- cbind(Name=SYMBOL,Change=CHANGE,Hom_Het=AF,Sense=SENSE,Clinic=CLINSIG,dbSNP=ID,Depth=DP,Allele_Balance=AB,ALL_1000=ALL_1000,EAS_1000=EAS_1000,SIFT_score=SS,SIFT_pred=SP,ClinicDescription=Des,Reference=ref)
filename <- sub("(.*).vcf","\\1",argv[1]) %>>% paste("exInfo",sep="_") %>>% paste("xlsx",sep=".") %>>% (paste("exInfo/",.,sep=""))
#write.table(Extract,file=filename,sep="\t",quote=F,row.names=F,col.names=T)
writeWorksheetToFile(filename,data=Extract,sheet="Sheet1",startRow=1,startCol=1)

#depth
bases <- read.table("bases.txt",header=F,sep="\t")
jpeg("exInfo/depth.jpg",width=640,height=480,quality=100)
par(mar=c(5,5,3,2))
(colSums(bases[,5:ncol(bases)])/sum(bases[,3]-bases[,2]+1)) %>>% (barplot(.,names.args=1:(ncol(bases)-4),main="Average depth of each sample",col=rainbow(length(.)),ylim=c(0,(max(.)+100)%/%100*100),las=2,xlab="Samples",ylab="Average depth"))
box()
abline(h=30,col="red")
dev.off()

for (i in 5:ncol(bases))
{
    name <- paste("exInfo/",i-4,"_depth.jpg",sep="")
    jpeg(name,width=640,height=480,quality=100)
    par(mar=c(5,5,3,2))
    (bases[,i]/(bases[,3]-bases[,2]+1)) %>>% (barplot(.,main="Average depth of each exon",col=rainbow(length(.)),ylim=c(0,(max(.)+100)%/%100*100),las=2,xlab="Exons in Genome",ylab="Depth"))
    box()
    abline(h=30,col="red")
    abline(h=20,col="blue")
    dev.off()
}
