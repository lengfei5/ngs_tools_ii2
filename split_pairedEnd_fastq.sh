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
for file in "$@"
do
    echo $file
    fname="${file%.fastq}"
    #echo $trimmed

    # creat the script for each sample
    script=$PWD/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=180
#SBATCH --mem=20G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR/logs/$fname.out
#SBATCH -e $DIR/logs/$fname.err
#SBATCH --job-name $jobName

bash ${deinterleaver} < ${file} ${fname}_R1.fastq ${fname}_R2.fastq

EOF

    cat $script;
    sbatch $script
    break;
    
done
