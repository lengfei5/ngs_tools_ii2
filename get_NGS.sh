#####
# this script is to down unaligned bam files using links sent from vbcf
# convert bam to fastq
####
# print host name and date
hostname
date

file_urls="URLs_download.txt"
nb_cores=1

cwd=`pwd`
DIR_BAMs=$PWD/ngs_raw/BAMs
DIR_FASTQs=$PWD/ngs_raw/FASTQs
mkdir -p $DIR_BAMs;
mkdir -p $cwd/logs;

# download bam files from links
while read -r line; do
    #echo $line;
    IFS=$'\t' read -r "id" "type" "flowcell" "lane" "result" "countsQ30" "distinct" "preparation" "own_risk" "url" "md5" "comment" <<<  "$line"
    #echo $line;
    #echo $url
    #echo $own_risk
    #echo $md5
    #exit;
    ff=`basename $url`
    #echo $ff;
    
    if [ ! -e "${DIR_BAMs}/$ff" ] && [ $url=="http:*" ]; then
	echo $url
	#echo $url2
	# download
	wget -c --no-check-certificate --auth-no-challenge --user 'Jingkui.Wang' --password "password" $url -P $DIR_BAMs
	# bamtofastq
	ff=`basename $file`
        #if [ -e "${DIR_BAMs}/$ff" ]; then
	out=${ff%.bam};
	echo $out
	qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star_mapping " module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}.fastq -o ${DIR_QC}; module load star/2.5.0a; STAR --runThreadN $nb_cores --genomeDir $GENOME --readFilesIn ${DIR_FASTQs}/${out}.fastq --outFileNamePrefix ${DIR_alignment}/$out --outSAMtype BAM SortedByCoordinate --outWigType wiggle --outWigNorm RPM; "
	
    else
	echo "$ff already downloaded ! "
    fi
done < "$file_urls"



