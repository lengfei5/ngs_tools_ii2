#######
# this script is to down unaligned bam files using links sent from vbcf
# convert bam to fastq
######
# print host name and date
hostname
date

file_urls="URLs_download.txt"
nb_cores=2

cwd=`pwd`
DIR_BAMs=$PWD/ngs_raw/BAMs
DIR_FASTQs=$PWD/ngs_raw/FASTQs
mkdir -p $DIR_BAMs;
mkdir -p $DIR_FASTQs;
mkdir -p $cwd/logs;

# download bam files from links
while IF=$'\t' read -r line; do
    echo $line;
    IFS=$'\t' read -r "id" "type" "flowcell" "lane" "result" "countsQ30" "distinct" "preparation" "own_risk" "url" "md5" "comment" <<<  "$line"
    #echo $line{@}
    #url=`echo $line |tr`
    #echo $line;
    echo $url
    #echo $own_risk
    #echo $md5
    #exit;
    ff=`basename $url`
    ff=${url##*/}
    echo $ff;
    
    if [ ! -e "${DIR_BAMs}/$ff" ] && [ $url=="http:*" ]; then
	#echo $url
	#echo $url2
	# download
	wget -c --no-check-certificate --auth-no-challenge $url -P $DIR_BAMs
			
    else
	echo "$ff already downloaded ! "
    fi
    
done < "$file_urls"

## convert bam to fastq
if [ `ls -l $DIR_BAMs/*.bam 2>/dev/null|wc -l` -gt 0 ]; then
    for file in $DIR_BAMs/*.bam;
    do 
	ff=`basename $file`
        out=${ff%.bam};
	echo $out
	if [ "${DIR_FASTQs}/${out}.fastq" -ot "$file" ]; then
	    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star_mapping " module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}.fastq -o ${DIR_QC};"
	
	fi
    done
else
    echo "No Bam files"
fi





