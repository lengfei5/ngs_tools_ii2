###################
## bam2fastq script
###################
DIR_INPUT="${PWD}/ngs_raw/BAMs"
DIR_OUT="${PWD}/ngs_raw/FASTQs"
dir_logs=$PWD/logs
#echo ${DIR_OUT};

mkdir -p ${DIR_OUT}

mkdir -p ${dir_logs}

for file in $DIR_INPUT/*.bam;
do 
    FILENAME="$(basename $file)";
    fname=${FILENAME%.bam};
    fname=${fname/\#/\_}
    echo "$file" $fname
    
    ## creat the script for each sample 
    script=${dir_logs}/${fname}_bam2fastq.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1 
#SBATCH --time=60 
#SBATCH --mem=10000 

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.out 
#SBATCH -e ${dir_logs}/${fname}.err 
#SBATCH --job-name bam2fq

module load bedtools/2.25.0-foss-2017a;
bamToFastq -i $file -fq ${DIR_OUT}/${fname}.fastq;
#gzip ${DIR_OUT}/${fname}.fastq

EOF
    
    #cat $script;
    sbatch $script
    #break;
    
done
