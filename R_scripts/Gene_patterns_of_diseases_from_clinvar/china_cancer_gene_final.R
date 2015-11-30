library(pipeR)

# Reading vcf from clinvar
clinvar <- readLines("~/Downloads/clinvar_20150804.vcf")

# Gene patterns, "breast",et al.
# You can use optional parameter "key" for special regular expression patterns.
# You can replace last "\\1" by "\\2" or "\\3" for different parts of GENEINFO
findGenes <- function(tissue,key="") {
	if (key == "")
	{
		first <- substr(tissue,1,1)
		rest <- substr(tissue,2,nchar(tissue))
		key <- paste("[",toupper(first),"|",tolower(first),"]",rest,sep="")
	}
	# Some SNVs have no GENEINFO,so need some dirty operations.
	t <- clinvar[grep(key,clinvar)] %>>% (regexpr("GENEINFO=(.*?);",.))
	t[t==-1] <- 0
	main <- t %>>% (regmatches(clinvar[grep(key,clinvar)],.)) %>>% (sub("GENEINFO=(.*?):(.*?)|(.*);","\\1",.))
	main[main==""] <- "NA"
#	Some genes overlap in hg19 assembly. Only need one gene name.
#	sub <- clinvar[grep(key,clinvar)] %>>% (regexpr("GENEINFO=(.*?);",.)) %>>% (regmatches(clinvar[grep(key,clinvar)],.)) %>>% (sub("GENEINFO=(.*?):(.*?)|(.*);","\\2",.)) %>>% (sub("(.*?)\\|(.*?):(.*);","\\2",.)) %>>% (.[grep("[a-z|A-Z]+",.)]) %>>% as.factor %>>% levels
#	return(c(main,sub) %>>% sort %>>% unique)
	return(main)
}

findGenes2 <- function(tissue,key="") {
	if (key == "")
	{
		first <- substr(tissue,1,1)
		rest <- substr(tissue,2,nchar(tissue))
		key <- paste("[",toupper(first),"|",tolower(first),"]",rest,sep="")
	}
	temp <- clinvar[grep(key,clinvar)]
	# Some SNVs have no GENEINFO,so need some dirty operations.
	t <- temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)] %>>% (regexpr("GENEINFO=(.*?);",.))
	t[t==-1] <- 0
	main <- t %>>% (regmatches(temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)],.)) %>>% (sub("GENEINFO=(.*?):(.*?)|(.*);","\\1",.))
	main[main==""] <- "NA"
#	Some genes overlap in hg19 assembly. Only need one gene name.
#	sub <- temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)] %>>% (regexpr("GENEINFO=(.*?);",.)) %>>% (regmatches(temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)],.)) %>>% (sub("GENEINFO=(.*?):(.*?)|(.*);","\\2",.)) %>>% (sub("(.*?)\\|(.*?):(.*);","\\2",.)) %>>% (.[grep("[a-z|A-Z]+",.)]) %>>% as.factor %>>% levels
#	return(c(main,sub) %>>% sort %>>% unique)
	return(main)
}

write.csv(findGenes("breast"),file="results/breast_genes.csv")
write.csv(findGenes2("lung"),file="results/lung_genes.csv")
write.csv(findGenes2("liver",key="[H|h]epat|[L|l]iver"),file="results/liver_genes.csv")
write.csv(findGenes("colorect"),file="results/colorect_genes.csv")
write.csv(findGenes("gastric"),file="results/gastric_genes.csv")
