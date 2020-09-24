###################
## bam2fastq script
###################
DIR_INPUT="${PWD}/ngs_raw"
#DIR_OUT="${PWD}/ngs_raw/FASTQs"
#dir_logs=$PWD/logs
#echo ${DIR_OUT};
#mkdir -p ${DIR_OUT}
DIR_pwd="$PWD"
#mkdir -p ${dir_logs}
cd $DIR_INPUT;

for file in *.bam;
do 
    #FILENAME="$(basename $file)";
    #fname=${file%.bam};
    newname=${file/\#/\_}
    echo "$file" "$newname" 

    mv $file $newname
    
    #reak;
    
done

cd $DIR_pwd
