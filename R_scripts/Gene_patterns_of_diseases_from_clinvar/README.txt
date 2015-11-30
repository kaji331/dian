Searching SNVs for tissues in downloaded ClinVar database, and generating bed files to be intersected by bedtools with hg19 KnownGenes for exons panel manufactures.

1. source("china_cancer_gene_final.R")
2. source("china_cancer_pos_final.R")
3. source("combine.R") -> snv
4. upload all bed files to Galaxy
5. use intersect interval files from bedtools to find exons of UCSC Main Human refGene coding (overlaps on either strand, -wa) -> exons
6. use realExons function to get corrected exons bed files by exons and snv

ps. steps 5 may be completed by bedops or R (GenomicRanges)
