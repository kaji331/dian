library(pipeR)

# Reading vcf from clinvar
clinvar <- readLines("~/Downloads/clinvar_20150804.vcf")

# Gene patterns, "breast",et al.
# You can use optional parameter "key" for special regular expression patterns.
# You can replace last "\\1" by "\\2" or "\\3" for different parts of GENEINFO
findPos <- function(tissue,key="") {
	if (key == "")
	{
		first <- substr(tissue,1,1)
		rest <- substr(tissue,2,nchar(tissue))
		key <- paste("[",toupper(first),"|",tolower(first),"]",rest,sep="")
	}
	chr <- clinvar[grep(key,clinvar)] %>>% (regexpr("^(.*?)\\\t",.)) %>>% (regmatches(clinvar[grep(key,clinvar)],.)) %>>% (sub("(.*?)\\\t","chr\\1",.))
	pos <- clinvar[grep(key,clinvar)] %>>% (regexpr("RSPOS=[0-9]+;",.)) %>>% (regmatches(clinvar[grep(key,clinvar)],.)) %>>% (sub("RSPOS=(.*?);","\\1",.))
	return(cbind(chr,pos,pos))
}

findPos2 <- function(tissue,key="") {
	if (key == "")
	{
		first <- substr(tissue,1,1)
		rest <- substr(tissue,2,nchar(tissue))
		key <- paste("[",toupper(first),"|",tolower(first),"]",rest,sep="")
	}
	temp <- clinvar[grep(key,clinvar)]
	chr <- temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)] %>>% (regexpr("^(.*?)\\\t",.)) %>>% (regmatches(temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)],.)) %>>% (sub("(.*?)\\\t","chr\\1",.))
	pos <- temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)] %>>% (regexpr("RSPOS=[0-9]+;",.)) %>>% (regmatches(temp[grep("[C|c]ancer|[C|c]arcinoma|[T|t]umor",temp)],.)) %>>% (sub("RSPOS=(.*?);","\\1",.))
	return(cbind(chr,pos,pos))
}

write.csv(findPos("breast"),file="results/breast_pos.csv")
write.csv(findPos2("lung"),file="results/lung_pos.csv")
write.csv(findPos2("liver",key="[H|h]epat|[L|l]iver"),file="results/liver_pos.csv")
write.csv(findPos("colorect"),file="results/colorect_pos.csv")
write.csv(findPos("gastric"),file="results/gastric_pos.csv")
