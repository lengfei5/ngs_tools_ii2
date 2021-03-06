##############################
# this script is to make BigWig files using bam files as inputs.
# current version is using deeptools to do so
# options to consider is strand-specific data (e.g. strand-specific RNA-seq)
#############################
while getopts ":hD:" opts; do
    case "$opts" in
        "h")
            echo "script to make BigWig files using bam as inputs"
            echo "current version is using deeptools v2.2.3 and python 2.7.3"
            echo "Usage:"
	    echo " -h  (help)"
	    echo " -D (directory for bam input or by defaut alignments/BAMs_All)"
	    echo "..... "
	    echo "Example:"
            echo "$0 (if bam files in alignments/BAMs_All for chipseq) "
            echo "$0 -D XXX (bam files in XXX directory)"
	    exit 0
            ;;
        "D")
            DIR_bams="$OPTARG"
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

nb_cores=16;

jobName='bamIndex'
dir_logs=${PWD}/logs

mkdir -p $dir_logs

for file in ${DIR_bams}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}
    
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

samtools sort -@ $nb_cores -o ${DIR_bams}/${fname}_sorte.bam $file

mkdir -p ${DIR_bams}/bam_backup
mv $file ${DIR_bams}/bam_backup
mv ${DIR_bams}/${fname}_sorte.bam ${DIR_bams}/${fname}.bam
samtools index -c -m 14 ${DIR_bams}/${fname}.bam

EOF
    
    cat $script;
    sbatch $script
    
    #break
   
done
