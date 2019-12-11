############
# this script is to run fastqc for the ngs data 
############
#nb_cores=1
cwd=$PWD
DIR_fastq="${PWD}/ngs_raw/FASTQs"
DIR_FastQCs=$PWD/ngs_raw/FASTQC;

mkdir -p ${DIR_FastQCs} 
mkdir -p $PWD/logs

## run fastQC for each fastq file
for file in ${DIR_fastq}/*.fastq;
do
    echo $file
    file_name="$(basename $file)"                                                                      
    fname=${file_name%.fastq}                                                                                                   
    echo $fname
    
    # make a script for every sample
    script=$PWD/logs/${fname}_fastqc.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=60
#SBATCH --mem=10000

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $PWD/logs/$fname.out
#SBATCH -e $PWD/logs/$fname.err
#SBATCH --job-name fastqc

module load fastqc/0.11.8-java-1.8;
fastqc $file -o ${DIR_FastQCs}

EOF

    cat $script;
    sbatch $script
done

