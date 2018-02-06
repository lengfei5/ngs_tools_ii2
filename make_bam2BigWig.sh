##############################
# this script is to make BigWig files using bam files as inputs.
# current version is using deeptools to do so
# options to consider is strand-specific data (e.g. strand-specific RNA-seq)
#############################
while getopts ":hD:s" opts; do
    case "$opts" in
        "h")
            echo "script to filter make BigWig files using bam files as inputs"
            echo "current version is using deeptools v2.2.3 and python 2.7.3"
            echo "Usage:"
            echo "$0 (if bam files in alignments/BAMs_All for chipseq) "
            echo "$0 -D XXX (bam files in XXX directory)"
            echo "$0 -s (strand-specific bams)"
	    exit 0
            ;;
        "D")
            DIR_bams="$OPTARG"
            ;;
	"s")
	    STRAND_specific="TRUE"
	    ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option -D "
	    exit 1; 
            ;;
    esac
done

nb_cores=4
if [ -z "$DIR_bams" ]; then
    DIR_bams="${PWD}/alignments/BAMs_All"
    echo "bam directory is $DIR_bams"
else
    # check if provided directory ends with slash 
    if [[ $DIR_bams == */ ]]; then
	echo "parsing bam directory "
	DIR_bams=${DIR_bams%/}
	
    fi
    echo "bam directory is $DIR_bams"
    # check if there are bam files in the directory or not
    if [ `ls -l $DIR_bams/*.bam|wc -l` == "1" ]; then
	echo "no bam Found !!! "
	echo " wrong directory or no bams in there "
	exit 1;
    fi

fi

MAPQ_cutoff=30;
OUT="${PWD}/bigWigs"
mkdir -p $OUT
mkdir -p ${PWD}/logs

#Genome="/home/imp/jingkui.wang/Genomes/C_elegans/ce10_index/ce10/ce10"
#chromSize="/groups/bell/jiwang/Genomes/C_elegans/ce10/ce10_sequence/ce10_chrom.sizes"
#chromSize="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/Sequence/mm10_chrom_sizes.sizes"

for b in ${DIR_bams}/*.bam;
#for bam in ${DIR_input}/42964_filter_rmdup.bam
do
    echo $b
    wig="$(basename $b)"
    wig="${wig%.bam}"
    echo $wig
    if [ "$STRAND_specific" != "TRUE" ]; then
	qsub -q public.q -o ${PWD}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N bamcoverage " if [ ! -e ${b}.bai ]; then module load samtools; samtools index $b; fi; if [ ! -e ${OUT}/${wig}.bw ]; then module unload deeptools; module load python/2.7.3; module load pysam/0.10.0; module load deeptools/2.2.3-python2.7.3; bamCoverage -b ${b} -o $OUT/${wig}.bw --outFileFormat=bigwig --normalizeUsingRPKM --ignoreDuplicates --minMappingQuality $MAPQ_cutoff; fi;"
    else
	echo "to complete"
    fi

    #qsub -q public.q -oqsub -q public.q -o ${PWD}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N bam2bw "module load samtools; module load rseqc/2.6.1-python2.7.3; module load kent-ucsc/2.79; TMP=`mktemp`; bam2wig.py -i $bam -s $chromSize -o \$TMP -t 200000000; if [ ! -e \$TMP.bw ]; then wigToBigWig \$TMP.wig $chromSize \$TMP.bw; fi; mv \$TMP.bw $DIR_output/$wig.bw; rm \$TMP*; " 
    #samtools view -q 10 -b $file | bedtools intersect -a stdin -b /groups/bell/jiwang/Genomes/C_elegans/ce10/ce10_blacklist/ce10-blacklist.bed -v | samtools sort - ${DIR_output}/$newb; samtools index ${DIR_output}/${newb}.bam; samtools rmdup -s ${DIR_output}/${newb}.bam ${DIR_r     mdup}/${newb}_rmdup.bam;samtools index ${DIR_rmdup}/${newb}_rmdup.bam;" 
    #break
done