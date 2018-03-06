#######
## this script is to convert raw data (undemultiplexed, sra and demultiplexed bam files) to fastq files
## Input: text file "URLs_download.txt", or sra files in ngs_raw/SRAs/ or bam files in ngs_raw/BAMs/
## convert bam to fastq
######
# print host name and date
hostname
date

while getopts ":hudsp" opts; do
    case "$opts" in
	"h")
	    echo "script to dowload demultipled bams from vbcf url, convert bam files, sra files and demultiplex bams "
            echo "Usage: dowload bams from url links and convert them to fastq" 
	    echo "$0 -u URL_dowload.txt "
	    echo "convert sra (in the folder of ngs_raw/SRAs) to fastq files "
	    echo "$0 -d "
	    echo "demultiplex bam files (in the folder of ngs_raw/RAWs) and convert them to fastq"
	    echo "$0 -s "
	    echo "convert bam files (in the folder of ngs_raw/BAMs) to fastq"
	    echo "$0 "
	    echo "convert paired-end bam files (in the folder of ngs_raw/BAMs) to fastq"
	    echo "$0 -p "
            exit 0
            ;;
	"u")
	    URL="TRUE"
	    ;;
	"d")
	    Demultiplex="TRUE"
	    ;;
 	"s")
	    SRA="TRUE"
	    ;;
	"p")
	    PAIRED="TRUE"
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
file_urls="URLs_download.txt" # download url file

DIR_FC=$PWD/ngs_raw/RAWs #folder for unsplitted bam 
DIR_SRA=$PWD/ngs_raw/SRAs #folder for SRA files
DIR_BAMs=$PWD/ngs_raw/BAMs #folder for splitted bam 
DIR_FASTQs=$PWD/ngs_raw/FASTQs #folder for fastq 
DIR_QC=$PWD/ngs_raw/FASTQC # folder for fast qc

mkdir -p $cwd/logs; # folder for logs 
mkdir -p $DIR_BAMs;
mkdir -p $DIR_FASTQs;
mkdir -p $DIR_QC;
  
## demultiplex raw bam files                                                                                  if [ -n "$Demultiplex" ]; then
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

## convert sra files to fastq or bam files
if [ -n "$SRA" ]; then
    echo "dealing with SRA files"
    echo "to complete !!!"
fi

## download bams files using a files containing url links from vbcf
if [ -n "$URL" ]; then
    while read -r line; do
        #echo $line;
	IFS=$'\t' read -r "id" "type" "flowcell" "lane" "result" "countsQ30" "distinct" "preparation" "own_risk" "url" "md5" "comment" <<<  "$line"
        #echo $line;
	echo $url
    
	ff=${url##*/}
        #echo $ff;
	if [ ! -e "${DIR_BAMs}/$ff" ] && [ `echo "$url" |grep "http"` ]; then
	    echo $url
	    #echo $url2
	    wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url -P $DIR_BAMs
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
	
	if [ "$PAIRED" != "TRUE" ]; then
	    echo "single-end bam "
	    if [ "${DIR_FASTQs}/${out}.fastq" -ot "$file" ]; then
		qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N bam2fastqc "module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}.fastq -o ${DIR_QC};"
	    fi
	else 
	    echo "paired-end bam"
	    if [ "${DIR_FASTQs}/${out}_R1.fastq" -ot "$file" ]; then
	        qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N bam2fastqc "module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}_R1.fastq  -fq2 ${DIR_FASTQs}/${out}_R2.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}_R1.fastq ${DIR_FASTQs}/${out}_R2.fastq -o ${DIR_QC};"
	    fi
	fi
    done
else
    echo "No Bam files"
fi



