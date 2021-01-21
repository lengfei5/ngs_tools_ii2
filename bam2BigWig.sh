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
	    echo " -m the mapping quality cutoff, the default is 10 "
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
	"m")
	    MAPQ_cutoff="$OPTARG"
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

if [ -z "$extsize" ]; then extsize=0; fi;

if [ -z "$MAPQ_cutoff" ]; then MAPQ_cutoff=30; fi;

nb_cores=16;

OUT="${PWD}/bigWigs_deeptools"
jobName='bam2bw'
dir_logs=${PWD}/logs

mkdir -p $OUT
mkdir -p $dir_logs

for file in ${DIR_bams}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}
    
    bam_sorted=${DIR_bams}/${fname}_sorted.bam
    wig=${fname}_mq_${MAPQ_cutoff}
    echo $wig
    script=${dir_logs}/${fname}_${jobName}.sh	
    
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=360
#SBATCH --mem=24000

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.${jobName}.out
#SBATCH -e ${dir_logs}/${fname}.${jobName}.err
#SBATCH --job-name $jobName

if [ ! -e ${bam_sorted}.csi ]; then
mkdir -p ${DIR_bams}/bam_backup; 
module load samtools/1.10-foss-2018b; 
samtools sort -@ 8 -o $bam_sorted $file
samtools index -c -m 14 $bam_sorted;
mv $file ${DIR_bams}/bam_backup;

fi; 

#ml load deeptools/3.3.1-foss-2018b-python-3.6.6;

EOF
 
    if [ "$STRAND_specific" != "TRUE" ]; then
	cat <<EOF >> $script
singularity exec --no-home --home /tmp /groups/tanaka/People/current/jiwang/local/deeptools_master.sif bamCoverage \
-b ${bam_sorted} \
-o ${OUT}/${wig}.bw \
--outFileFormat=bigwig \
--normalizeUsing CPM \
--ignoreDuplicates \
--minMappingQuality $MAPQ_cutoff \
-p ${nb_cores} \
--binSize 100 
 
EOF

    else
	cat <<EOF >> $script
bamCoverage -b ${file} \
--filterRNAstrand forward \
-o ${OUT}/${wig}_fwd.bw \
--outFileFormat=bigwig \
--normalizeUsing CPM \
--ignoreDuplicates \
--minMappingQuality $MAPQ_cutoff \
--extendReads ${extsize} \
-p ${nb_cores} \
--binSize 1

bamCoverage -b ${file} \
--filterRNAstrand reverse \
-o ${OUT}/${wig}_rev.bw \
--outFileFormat=bigwig \
--normalizeUsing CPM \
--ignoreDuplicates \
--minMappingQuality $MAPQ_cutoff \
--extendReads ${extsize} \
-p ${nb_cores} \
--binSize 1

EOF
    fi
    
    cat $script;
    sbatch $script
    
    #break
   
done
