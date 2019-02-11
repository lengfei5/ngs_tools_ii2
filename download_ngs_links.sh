#########################################
# download ngs data using URL links
# input: text file with url download links
# output: downloaed bam files in the current directory
# not yet updated for the ii2 cluster
#########################################
file_urls="$1";
nb_cores=1;
DIR_cwd=`pwd`;
mkdir -p $PWD/logs

while read -r line; do
    #echo $line;
    url=`echo "$line" | tr '\t' '\n'|grep "http\|ftp"`
    if [ -n "$url" ]; then
	file=`basename $url`
  	ext="${file##*.}"
	if [ ! -e "$file" ]; then
	    #echo "here"
	    echo $url
	    echo $file
	    echo $ext
	    #qsub -q public.q -o $DIR_cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N download "wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url; touch $file; if [ '$ext' == 'gz' ]; then gunzip $file; fi "
	    wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url; 
	    touch $file; 
	    if [ '$ext' == 'gz' ]; then 
		gunzip $file; 
	    fi
	else
	    echo "$file -- downloaded !!!"
	fi
    fi
    
    #break;
    
done < "$file_urls"
