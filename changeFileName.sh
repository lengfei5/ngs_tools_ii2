############################
# This script is to copy file and change file's name
# this should be done before mapping to the genome
# # there are bugs in this code, further check required
##########################
#set -u;
while getopts ":hD:f:" opts; do
    case "$opts" in
        "h")
            echo "script to change file names with two arguments required"
	    echo "-D the directory of files "
	    echo "-f the file for the processed design matrix for the sample information"
            echo "Usage: "
            echo "$0 -D alignments/BAMs_All -f Design_matrix_manual_R6118_parsed.txt"
            exit 0
            ;;
        "D")
            DIR="$OPTARG";
            ;;
        "f")
            PARAM="$OPTARG";
            ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option $opts"
	    ;;
        esac
done

#DIR="$1";
#DIR="$PWD/ngs_raw/FASTQs"
#DIR_OUT="$PWD/ngs_raw/FASTQs"

if [ ! -d "$DIR" ]; then
    echo "Directory missing..."
    exit 1;
fi

if [ ! -e "$PARAM" ]; then
    echo "design matrix file missing..."
else
    PARAM=${PWD}/${PARAM}
fi

cwd=$PWD;
#PARAM="${PWD}/sampleInformation.txt"
#mkdir -p $DIR_OUT

echo $DIR, $PARAM;
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
