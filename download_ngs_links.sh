#########################################
# download ngs data using URL links
#
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
		
	if [ ! -e "$file" ]; then
	    #echo "here"
	    echo $url
	    echo $file
	    qsub -q public.q -o $DIR_cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N download "wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url; touch $file;"

	else
	    echo "$file -- downloaded !!!"
	fi
    fi
    
    #IFS=$'\t' read -r "ID" "url" <<< "$line"
    #echo $url
    #wget $url 
    #break;
done < "$file_urls"