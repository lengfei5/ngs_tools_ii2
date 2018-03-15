#########################################
# download ngs data using URL links
#
#########################################
file_urls="$1";
#file_urls="URLs_modEncode_histone_marks.txt"
#$OUT="$PWD/DATA/"

while read -r line; do
    #echo $line;
    url=`echo "$line" | tr '\t' '\n'|grep "http"`
    if [ -n "$url" ]; then
	echo $url
	file=`basename $url`
	#echo $file
	if [ ! -z '$file' ]; then
	    wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url;
	fi
    fi
    #IFS=$'\t' read -r "ID" "url" <<< "$line"
    #echo $url
    #wget $url 
    #break;
done < "$file_urls"