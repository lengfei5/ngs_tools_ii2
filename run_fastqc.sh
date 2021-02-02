############
# this script is to run fastqc for the ngs data 
############
#nb_cores=1
cwd=$PWD
DIR_fastq="${PWD}/ngs_raw/FASTQs_toTrim"
DIR_FastQCs=$PWD/ngs_raw/FASTQC;
DIR_QCs=$PWD/QCs/cnt_raw

mkdir -p ${DIR_FastQCs}
mkdir -p ${DIR_QCs}
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
#SBATCH --time=180
#SBATCH --mem=8G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $PWD/logs/$fname.out
#SBATCH -e $PWD/logs/$fname.err
#SBATCH --job-name fastqc

module load fastqc/0.11.8-java-1.8;
#fastqc $file -o ${DIR_FastQCs}

cat $file | paste - - - - | wc -l > ${DIR_QCs}/${fname}.totalcnt.txt

EOF

    cat $script;
    sbatch $script
    break;
    
done

