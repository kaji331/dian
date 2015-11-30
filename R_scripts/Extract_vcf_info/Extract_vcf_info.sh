#!/bin/sh

file=`ls *.vcf`
mkdir -p exInfo
for i in $file
do
    Rscript --slave Extract_vcf_info.R $i
done
