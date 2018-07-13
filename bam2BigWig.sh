##############################
# this script is to make BigWig files using bam files as inputs.
# current version is using deeptools to do so
# options to consider is strand-specific data (e.g. strand-specific RNA-seq)
#############################
while getopts ":hD:se:" opts; do
    case "$opts" in
        "h")
            echo "script to make BigWig files using bam as inputs"
            echo "current version is using deeptools v2.2.3 and python 2.7.3"
            echo "Usage:"
	    echo " -h  (help)"
	    echo " -D (ABSOLUTE directory for bam input or by defaut alignments/BAMs_All)"
	    echo " -s (strand-specific, defaut is no)"
	    echo " -e INT extend read length, the default is 0 bp "
	    echo "..... "
	    echo "Example:"
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
	"e")
	    extsize="$OPTARG";
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

nb_cores=2

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

if [ -z "$extsize" ]; then
    extsize=0;
fi

MAPQ_cutoff=10;
OUT="${PWD}/bigWigs"
mkdir -p $OUT
mkdir -p ${PWD}/logs

for b in ${DIR_bams}/*.bam;
#for bam in ${DIR_input}/42964_filter_rmdup.bam
do
    echo $b
    wig="$(basename $b)"
    wig="${wig%.bam}"
    echo $wig
    if [ "$STRAND_specific" != "TRUE" ]; then
	qsub -q public.q -o ${PWD}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N bamcoverage " if [ ! -e ${b}.bai ]; then module load samtools; samtools index $b; fi; if [ ! -e ${OUT}/${wig}.bw ]; then module unload deeptools; module load python/2.7.3; module load pysam/0.10.0; module load deeptools/2.2.3-python2.7.3; bamCoverage -b ${b} -o $OUT/${wig}.bw --outFileFormat=bigwig --normalizeUsingRPKM --ignoreDuplicates --minMappingQuality $MAPQ_cutoff --extendReads $extsize; fi;"
    else
	echo "to complete"
    fi

done