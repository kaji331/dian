# tissue is character. exons and snv are GenomicRanges imported by rtracklayer package
realExons <- function(tissue,exons,snv) {
  fname <- paste(tissue,"_exons_ranges.bed",sep="")
  require(rtracklayer)
  # remove duplicated regions
  exons <- disjoin(exons)
  # fix position number
  temp <- start(snv)
  start(snv) <- end(snv)
  end(snv) <- temp
  # gene names of each exons
  require(pipeR)
  real <- subsetByOverlaps(exons,snv)
  index <- findOverlaps(real,snv) %>>% queryHits
  name <- findOverlaps(real,snv) %>>% subjectHits %>>% (mcols(snv)[.,1])
  temp <- rep("test",nrow(mcols(real)))
  temp[index] <- name
  mcols(real) <- temp
  # write files
  cbind(as.character(seqnames(real)),start(real),end(real),as.character(strand(real)),
        mcols(real)[,1]) %>>%
    write.table(file=fname,quote=F,sep="\t",row.names=F,col.names=F)
}