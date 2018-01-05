OUT=`pwd`;
CORES=8;
mkdir -p $PWD/logs
for file in `find /groups/bell/jiwang/Projects/GSE55698_Blackledge_2014/ftp-trace.ncbi.nlm.nih.gov/ -name *.sra`;
do 
    echo $file;
    name=`basename $file`
    name=${name%.sra}
    qsub -q public.q -o logs/ -j yes -N sra2fastq -cwd -b y -pe smp $CORES -shell y "module load sra-toolkit/2.3.2-4; fastq-dump $file "
    #break;
done