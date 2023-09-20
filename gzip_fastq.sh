###############
## this script is to split paired_end fastq file into forward and reverse fastq files
## by involking another function deinterleave_fastq.sh
## now old version for ii1 is saved in another script
## this one is adapted for CBE
###############
DIR=`pwd`

mkdir -p "${DIR}/logs"

jobName='gzip_fastq'

for file in ${PWD}/*.fastq
#for file in `find ${PWD} -name '*.bam' -size +30G`
do
    echo $file
    
    fname="$(basename $file)"
    fname="${fname%.fastq}"
    fname=${fname/\#/\_}

    echo $fname
    
    # creat the script for each sample
    script=${DIR}/logs/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=0-4:00:00
#SBATCH --qos=short
#SBATCH --mem=8G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR/logs/$fname.out
#SBATCH -e $DIR/logs/$fname.err
#SBATCH --job-name $jobName

gzip $file

EOF

    cat $script;
    sbatch $script
    #break;
    
done
