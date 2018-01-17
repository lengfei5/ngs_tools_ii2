file_urls="URLs_modEncode_histone_marks.txt"
$OUT="$PWD/DATA/"

while read -r line; do
    echo $line;
    IFS=$' ' read -r "ID" "url" <<< "$line"
    echo $url
    wget $url 
    #break;
done < "$file_urls"