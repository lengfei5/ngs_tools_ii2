#####
## this script is to demultiplex the bam files from vbcf
####

INDEXREAD="TRUE"
nb_cores=20
DIR_cwd=`pwd`
DIR_FC=$PWD/ngs_raw/RAWs
DIR_OUT=$PWD/ngs_raw/BAMs

mkdir -p $DIR_OUT;
mkdir -p $DIR_cwd/logs;
#cd ngs_raw
#mkdir -p RAWS

cd $DIR_FC;
## demultiplex raw data
for RAW in ${DIR_FC}/*.bam; do
    echo $RAW
    
    if [ $INDEXREAD != "TRUE" ]; then
    
	qsub -q public.q -o $DIR_cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N demultiplex \
	    "/groups/vbcf-ngs/bin/funcGen/jnomicss.sh illumina2BamSplit --inputFile $RAW"
    else
        qsub -q public.q -o $DIR_cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N demultiplex \
	    "/groups/vbcf-ngs/bin/funcGen/jnomicss.sh illumina2BamSplit --inputFile $RAW \
            --indexRead dual2 --maxMismatches 1 --dualParam 0-0-1;" 
            #--correctdual none --dualBClength1 8 --dualBClength2 8"            
            #--indexRead dual2 --dualBClength1 6 --correctdual standard"
    fi;
    
done
cd $DIR_cwd