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
	file=`basename $url`
		
	if [ ! -e "$file" ]; then
	    #echo "here"
	    echo $url
	    echo $file
	    wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url;
	else
	    echo "$file -- downloaded !!!"
	fi
    fi
    
    #IFS=$'\t' read -r "ID" "url" <<< "$line"
    #echo $url
    #wget $url 
    #break;
done < "$file_urls"