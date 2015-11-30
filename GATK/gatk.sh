#!/bin/bash

#date

java -Xmx6G -jar /home/galaxy/command_pipelines/picard-tools-1.137/picard.jar MarkDuplicates \
	INPUT=$1 \
	OUTPUT=$(basename $1 .bam)\_md.bam \
	METRICS_FILE=$(basename $1 .bam)\_metrics.txt

mv $(basename $1 .bam)\_md.bam $(basename $1 .bam)\_$2.bam

java -Xmx6G -jar /home/galaxy/command_pipelines/picard-tools-1.137/picard.jar AddOrReplaceReadGroups \
	INPUT=$(basename $1 .bam)\_$2.bam \
	OUTPUT=$(basename $1 .bam)\_md.bam \
	ID=$(basename $1 .bam) \
	LB=MiSeq \
	PL=illumina \
	PU=$2 \
	SM=$(basename $1 .bam)

rm $(basename $1 .bam)\_$2.bam

/home/galaxy/command_pipelines/samtools/samtools-1.2/samtools index $(basename $1 .bam)\_md.bam

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T RealignerTargetCreator \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_md.bam \
	-nt 8 \
	-known /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-known /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-o $(basename $1 .bam)\_targets.list

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T IndelRealigner \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_md.bam \
	-targetIntervals $(basename $1 .bam)\_targets.list \
	-known /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-known /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-o $(basename $1 .bam)\_realign.bam

rm $(basename $1 .bam)\_md.bam
rm $(basename $1 .bam)\_md.bam.bai

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_realign.bam \
	-knownSites /bio01/Downloads/bundle/dbsnp_138.hg19.vcf \
	-knownSites /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-knownSites /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-o $(basename $1 .bam)\_recal.table

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_realign.bam \
	-knownSites /bio01/Downloads/bundle/dbsnp_138.hg19.vcf \
	-knownSites /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-knownSites /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-BQSR $(basename $1 .bam)\_recal.table \
	-o $(basename $1 .bam)\_post\_recal.table

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T AnalyzeCovariates \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-before $(basename $1 .bam)\_recal.table \
	-after $(basename $1 .bam)\_post\_recal.table \
	-plots $(basename $1 .bam)\_recal.pdf \
	-csv $(basename $1 .bam)\_recal.csv

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T PrintReads \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_realign.bam \
	-BQSR $(basename $1 .bam)\_recal.table \
	-o $(basename $1 .bam)\_recal.bam

rm $(basename $1 .bam)\_realign.bam
rm $(basename $1 .bam)\_realign.bai

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_recal.bam \
	-L $3 \
	--genotyping_mode DISCOVERY \
	-stand_emit_conf 10 \
	-stand_call_conf 30 \
	-o $(basename $1 .bam).vcf

echo "Last status:"
if [ $? -eq 0 ]
then
	echo "OK"
else
	echo "Oh, no!"
fi

rm $(basename $1 .bam)\_recal.bam
rm $(basename $1 .bam)\_recal.bai

Rscript --slave /home/galaxy/command_pipelines/GATK/remove_low_quality.R $(basename $1 .bam).vcf
head -n 120 $(basename $1 .bam).vcf > $(basename $1 .bam)\_start.vcf
cat $(basename $1 .bam)\_start.vcf $(basename $1 .bam)\_end.vcf > $(basename $1 .bam)\_gatk.vcf
rm $(basename $1 .bam).vcf $(basename $1 .bam)\_start.vcf $(basename $1 .bam)\_end.vcf

# gzip $(basename $1 .bam)\_gatk.vcf

#date
