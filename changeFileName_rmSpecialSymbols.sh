###################
## bam2fastq script
###################
DIR_INPUT="${PWD}/ngs_raw"
dir_logs=$PWD/logs
#echo ${DIR_OUT};

mkdir -p ${DIR_OUT}
mkdir -p ${dir_logs}

for file in $DIR_INPUT/*.fastq;
do 
    FILENAME="$(basename $file)";
    #fname=${FILENAME%.fastq};
    fname=${FILENAME/\#/\_}
    echo "$file"
    echo ${DIR_INPUT}/$fname
    
    mv $file ${DIR_INPUT}/$fname
    
done
