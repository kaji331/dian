#!/bin/sh

/home/galaxy/command_pipelines/bwa/bwa-0.7.12/bwa mem -t 8 /bio01/Downloads/ucsc.hg19.fasta $1 $2 \
	| pigz -3 -p 8 > $(basename $1 .fastq.gz).sam.gz
/home/galaxy/command_pipelines/samtools/samtools-1.2/samtools view -@ 8 -S -b -o $(basename $1 .fastq.gz).bam $(basename $1 .fastq.gz).sam.gz
rm $(basename $1 .fastq.gz).sam.gz
/home/galaxy/command_pipelines/samtools/samtools-1.2/samtools sort -@ 8 $(basename $1 .fastq.gz).bam $(basename $1 .fastq.gz)\_sorted
rm $(basename $1 .fastq.gz).bam
