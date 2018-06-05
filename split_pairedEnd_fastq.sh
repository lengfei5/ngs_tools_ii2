###############
## this script is to split paired_end fastq file into forward and reverse fastq files
## by involking another function deinterleave_fastq.sh
###############
nb_cores=6
cwd=`pwd`
deinterleaver="/home/imp/jingkui.wang/scripts/ngs_tools/deinterleave_fastq.sh"

#fastqs=$1
#echo 
#DIR_input="${cwd}/ngs_raw/FASTQs_toTrimmed"
#DIR_trimmed="${cwd}/ngs_raw/FASTQs"
#echo $DIR_input
#echo $DIR_trimmed

mkdir -p "${cwd}/logs"
#mkdir -p $DIR_trimmed

for file in "$@" 
do
    echo $file
    split_fastq="${file%.fastq}"
    #echo $trimmed
    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N splitFastq "bash ${deinterleaver} < ${file} ${split_fastq}_R1.fastq ${split_fastq}_R2.fastq; "

done
