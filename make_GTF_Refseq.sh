rsync -a -P rsync://hgdownload.soe.ucsc.edu/goldenPath/mm9/database/refGene.txt.gz ./
gzip -d refGene.txt.gz
cut -f 2- refGene.txt > refGene.input
module load kent-ucsc/2.79
genePredToGtf file refGene.input mm9refGene.gtf
cat mm9refGene.gtf  | sort -k1,1 -k4,4 > mm9refGene_sorted.gtf 