#!/bin/sh

file=`ls *.vcf`
mkdir -p rmInfo
for i in $file
do
    Rscript --slave Del_vcf_info.R $i
done
