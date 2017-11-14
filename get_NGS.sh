#######
# this script is to down unaligned bam files using links sent from vbcf
# convert bam to fastq
######
# print host name and date
hostname
date

while getopts ":ds" opts; do
    case "$opts" in 
	"d")
	    Demultiplex="TRUE"
	    ;;
	"s")
	    SRA="TRUE"
	    ;;
	"?")
	    echo "Unknown option $opts"
	    ;;
	":")
	    echo "No argument value for option $opts"
	    ;;
	
	esac
done

nb_cores=2
cwd=`pwd`

DIR_FC=$PWD/ngs_raw/RAWs #folder for unsplitted bam 
DIR_SRA=$PWD/ngs_raw/SRAs #folder for SRA files
DIR_BAMs=$PWD/ngs_raw/BAMs #folder for splitted bam 
DIR_FASTQs=$PWD/ngs_raw/FASTQs #folder for fastq 
DIR_QC=$PWD/ngs/FASTQC # folder for fast qc
mkdir -p $cwd/logs; # folder for logs 

## demultiplex raw bam files                                                                                                                            
if [ -n "$Demultiplex" ]; then
    echo "start to demultiplex the bam file"
    mkdir -p $DIR_BAMs;
    cd $DIR_FC;
    for RAW in ${DIR_FC}/*.bam; do
	echo $RAW
	FC=`echo $RAW | cut -d"_" -f1`;
	lane=`echo $RAW | cut -d"_" -f2`;
	echo $FC $lane;
	qsub -q public.q -o ${cwd}/logs -j yes -pe smp 8 -cwd -b y -shell y -N demultiplex  "/groups/vbcf-ngs/bin/funcGen/jnomicss.sh illumina2BamSplit --inputFile $RAW; mv ${FC}_demux_${lane}/*#[^0]*.bam $DIR_BAMs;"
    done
    cd $cwd;
fi

if [ -n "$SRA" ]; then
    echo "dealing with SRA files"
 
fi

if [ -z $Demultiplex ] && [ -z $SRA ]; then
    file_urls="URLs_download.txt"
    
    mkdir -p $DIR_BAMs;
    mkdir -p $DIR_FASTQs;
    mkdir -p $DIR_QC;
    
    # download bam files from links
    while read -r line; do
        #echo $line;
	IFS=$'\t' read -r "id" "type" "flowcell" "lane" "result" "countsQ30" "distinct" "preparation" "own_risk" "url" "md5" "comment" <<<  "$line"
        #echo $line;
	echo $url
    
	ff=${url##*/}
        #echo $ff;
	if [ ! -e "${DIR_BAMs}/$ff" ] && [ `echo "$url" |grep "http"`]; then
	    echo $url
	    #echo $url2
	    wget -c --no-check-certificate --auth-no-challenge $url -P $DIR_BAMs
	else
	    echo "$ff already downloaded ! "
	fi
    
    done < "$file_urls"
fi

#convert bam to fastq
while [ `qstat | wc -l` -gt 0 ]; do
    sleep 180
done

if [ `ls -l $DIR_BAMs/*.bam 2>/dev/null|wc -l` -gt 0 ]; then
    for file in $DIR_BAMs/*.bam;
    do 
	ff=`basename $file`
        out=${ff%.bam};
	echo $out
	if [ "${DIR_FASTQs}/${out}.fastq" -ot "$file" ]; then
	    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star_mapping "module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}.fastq -o ${DIR_QC};"
	fi
    done
else
    echo "No Bam files"
fi



