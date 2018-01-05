############
# this script is to run fastqc for the ngs data 
############
nb_cores=2
cwd=$PWD

DIR_fastq="${PWD}/ngs_raw/FASTQs"
#echo $DIR_fastq
DIR_FastQCs=$PWD/ngs_raw/FastQCs;

mkdir -p $PWD/logs
mkdir -p ${DIR_FastQCs} 

## run fastQC for quality control
for file in ${DIR_fastq}/*.fastq;
do
    echo $file
    index_name="$(basename $file)"                                                                                                                                                                                                                        
    fname=${index_name%.bam}                                                                                                                                                                                                                               
    #echo $fname                                                                                                                                                                                                                                        
    qsub -q public.q -o $cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N fastqc "module load fastqc; fastqc $file -o ${DIR_FastQCs} "
done

