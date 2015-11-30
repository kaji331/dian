#!/bin/bash

# $1 is R1 reads, $2 is R2 reads, $3 is panel name, $4 is bed file, $5 is clinvar vcf file.

# Trimming
/home/galaxy/command_pipelines/trimmomatic.sh $1 $2

# BWA
/home/galaxy/command_pipelines/bwa/bwa.sh $(basename $1 .fastq.gz)\_trimmed.fastq.gz $(basename $2 .fastq.gz)\_trimmed.fastq.gz

/home/galaxy/command_pipelines/samtools/samtools-1.2/samtools index $(basename $1 .fastq.gz)\_trimmed\_sorted.bam

# GATK
/home/galaxy/command_pipelines/GATK/gatk.sh $(basename $1 .fastq.gz)\_trimmed\_sorted.bam $3 $4

# Annotation
/home/galaxy/command_pipelines/annovar_gatk.sh $(basename $1 .fastq.gz)\_trimmed\_sorted\_gatk.vcf $5

# Preparing for extracting information and drawing plots
mkdir -p results
mv $(basename $1 .fastq.gz)\_trimmed\_sorted\_gatk\_final.vcf results/
/home/galaxy/command_pipelines/samtools/samtools-1.2/samtools bedcov $4 *sorted.bam > bases.txt
mv bases.txt results/
mv $(basename $1 .fastq.gz)*.pdf results/
#rm $(basename $1 .fastq.gz)*trimmed* $(basename $2 .fastq.gz)*trimmed*
rm snpEff*
