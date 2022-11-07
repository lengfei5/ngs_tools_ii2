###############
## this script is to split paired_end fastq file into forward and reverse fastq files
## by involking another function deinterleave_fastq.sh
## now old version for ii1 is saved in another script
## this one is adapted for CBE
###############
DIR=`pwd`
deinterleaver="~/scripts/ngs_tools/deinterleave_fastq.sh"

mkdir -p "${DIR}/logs"
#mkdir -p $DIR_trimmed

jobName='splitPE'

#for file in ${PWD}/*.bam
for file in `find ${PWD} -name '*.bam' -size +30G`
do
    echo $file
    
    fname="$(basename $file)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}

    echo $fname
    
    # creat the script for each sample
    script=${DIR}/logs/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=0-24:00:00
#SBATCH --qos=medium
#SBATCH --mem=4G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR/logs/$fname.out
#SBATCH -e $DIR/logs/$fname.err
#SBATCH --job-name $jobName

module load bedtools/2.25.0-foss-2018b;

bamToFastq -i $file -fq ${fname}.fastq
bash ${deinterleaver} < ${fname}.fastq ${fname}_R1.fastq ${fname}_R2.fastq
gzip ${fname}_R1.fastq
gzip ${fname}_R2.fastq 

EOF

    cat $script;
    sbatch $script
    #break;
    
done
