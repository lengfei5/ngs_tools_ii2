##############################
# this script is to make BigWig files using bam files as inputs.
# current version is using deeptools to do so
# options to consider is strand-specific data (e.g. strand-specific RNA-seq)
#############################
while getopts ":hD:O:spe:f:m:" opts; do
    case "$opts" in
        "h")
            echo "script to make BigWig files using bam as inputs"
            echo "current version is using deeptools v2.2.3 and python 2.7.3"
            echo "Usage:"
	    echo " -h  (help)"
	    echo " -D (ABSOLUTE directory for bam input or by defaut alignments/BAMs_All)"
	    echo " -O output directory "
	    echo " -s (strand-specific, defaut is no)"
	    echo " -p (pair-ended, defaut is single end)"
	    echo " -e INT extend read length, the default is 0 bp "
	    echo " -f the file for sample id and scaling factor "
	    echo " -m the mapping quality cutoff, the default is 30 "
	    echo "..... "
	    echo "Example:"
            echo "$0 (if bam files in alignments/BAMs_All for chipseq) "
            echo "$0 -D XXX (bam files in XXX directory)"
            echo "$0 -s (strand-specific bams) -p (pair-ended) -f DESeq2_scalingFactor_forDeeptools.txt"
	    exit 0
            ;;
        "D")
            DIR_bams="$OPTARG"
            ;;
	"O")
            OUT="$OPTARG"
            ;;
	"s")
	    STRAND_specific="TRUE"
	    ;;
	"p")
	    pair_end="TRUE"
	    ;;
	
	"e")
	    extsize="$OPTARG";
	    ;;
	"f")
	    sf="$OPTARG";
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

if [ -z "$OUT" ]; then 
    OUT="${PWD}/bigwigs_deeptools.scalingFactor"
fi

jobName='bam2bw'
dir_logs=${PWD}/logs

mkdir -p $OUT
mkdir -p $dir_logs

while read -r line; do  
#for file in ${DIR_bams}/*.bam;
    read -r "ID" "scaling" <<< "$line"
    file=`ls ${DIR_bams}/*.bam |grep $ID`
    echo $file $scaling
    fname="$(basename $file)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}
    
    bam_save=${DIR_bams}/${fname}.bam
    bam_sorted=${DIR_bams}/${fname}_sorted.bam
    wig=${fname}_mq_${MAPQ_cutoff}
    echo $wig
    script=${dir_logs}/${fname}_${jobName}.sh	
    
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=480
#SBATCH --mem=32G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.${jobName}.out
#SBATCH -e ${dir_logs}/${fname}.${jobName}.err
#SBATCH --job-name $jobName

module load samtools/1.10-foss-2018b;

if [ ! -e ${bam_save}.csi ]; then

mkdir -p ${DIR_bams}/bam_backup;  
samtools sort -@ $nb_cores -o $bam_sorted $file
mv $file ${DIR_bams}/bam_backup;
mv $bam_sorted $bam_save
samtools index -c -m 14 $bam_save;

fi; 

#ml load deeptools/3.3.1-foss-2018b-python-3.6.6;

EOF

    if [ "$pair_end" == "TRUE" ]; then
	cat <<EOF >> $script

singularity exec --no-home --home /tmp /groups/tanaka/People/current/jiwang/local/deeptools_master.sif bamCoverage \
-b ${bam_save} \
-o ${OUT}/${wig}.bw \
--outFileFormat=bigwig \
--normalizeUsing CPM \
-p ${nb_cores} \
--binSize 20 \
--extendReads \
--minMappingQuality $MAPQ_cutoff \
--scaleFactor $scaling

EOF
    else
	cat <<EOF >> $script

singularity exec --no-home --home /tmp /groups/tanaka/People/current/jiwang/local/deeptools_master.sif bamCoverage \
-b ${bam_save} \
-o ${OUT}/${wig}.bw \
--outFileFormat=bigwig \
--normalizeUsing CPM \
-p ${nb_cores} \
--binSize 20 \
--minMappingQuality $MAPQ_cutoff \
--scaleFactor $scaling

EOF
    fi
    
    cat $script;
    sbatch $script
    #break
   
done < "$sf"
