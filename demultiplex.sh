#####
## this script is to demultiplex the bam files from vbcf
####
INDEXREAD="FALSE"
jobName='demultiplex'

DIR_cwd=`pwd`
DIR_FC=$PWD/ngs_raw/RAWs
DIR_OUT=$PWD/ngs_raw/BAMs
dir_logs=$PWD/logs

mkdir -p $DIR_OUT;
mkdir -p $dir_logs;
cd $DIR_FC;

## demultiplex raw data
for RAW in ${DIR_FC}/*.bam; do
    echo $RAW
    FILENAME="$(basename $RAW)";
    fname=${FILENAME%.*}
    fname=${fname/\#/\_}
    echo "$file" $fname
    
    script=${fname}_${jobName}.sh
cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=6
#SBATCH --time=4:00:00
#SBATCH --mem=20000
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $dir_logs/${fname}.out
#SBATCH -e $dir_logs/${fname}.err
#SBATCH --job-name $jobName

ml load java/1.8.0_121
EOF
    
    if [ $INDEXREAD != "TRUE" ]; then
	cat <<EOF >> $script
/groups/vbcf-ngs/bin/funcGen/jnomicss.sh illumina2BamSplit --inputFile $RAW --toFastq
EOF
    else
	cat <<EOF >> $script
/groups/vbcf-ngs/bin/funcGen/jnomicss.sh illumina2BamSplit --inputFile $RAW \
--indexRead dual2 --maxMismatches 1 --dualParam 0-0-1  --toFastq
EOF
    fi;
    
    
    cat $script;
    sbatch $script
    #break;    
done

cd $DIR_cwd
