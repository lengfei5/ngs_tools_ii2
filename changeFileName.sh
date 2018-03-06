############################
# This script is to copy file and change file's name
# this should be done before mapping to the genome
#
##########################
set -u;

DIR="$1";
#DIR="$PWD/ngs_raw/FASTQs"
#DIR_OUT="$PWD/ngs_raw/FASTQs"

if [ ! -d "$DIR" ]; then
    exit 1;
fi

cwd=$PWD;
PARAM="${PWD}/sampleInformation.txt"

#mkdir -p $DIR_OUT
cd $DIR

i=1;
while read -r line;
do 
    read -r "ID" "condition"  <<< "$line"
    if [[ $i -gt 1 ]]; then
	echo $ID;
	files=( $(ls -l | grep $ID | awk '{print $9}') )
	#echo ${files[@]};
	#echo ${#old[@]};
	if [ ${#files[@]} -ge 1 ]; then
	    for old in "${files[@]}"
	    do 
		#extension=`echo "$old" | cut -d'.' -f2`
		extension=${old#*.}
		#echo $extension;
		#extension="bam.bai"
		new=${condition}_${ID}.${extension};
		echo $old;
		echo $new
	        #cp "$old" $DIR_OUT
	        mv "$old" "$new"
	        #mv "$new" $DIR_OUT
	    done
	else
	    echo "NO FILES found"
	fi
	
    fi
    
    i=$((i + 1));
    #IFS=$','
done < "$PARAM"

cd $cwd;
