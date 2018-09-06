############################
# This script is to copy file and change file's name
# this should be done before mapping to the genome
# # there are bugs in this code, further check required
##########################
#set -u;
while getopts ":hD:f:" opts; do
    case "$opts" in
        "h")
            echo "script to change file names (usually fastq or bam)"  
	    echo "the file names would be done for bam (before or after alignment, or fastq)"
	    echo "Two arguments required"
	    echo "-D the directory of files (the folder for fastq or bam) "
	    echo "-f the file for the processed design matrix for the sample information"
            echo "Usage:"
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

if [ ! -d "$DIR" ]; then
    echo "Directory missing..."
    exit 1;
fi

if [ ! -e "$PARAM" ]; then
    echo "design matrix file missing..."
    exit 1;
else
    PARAM=${PWD}/${PARAM}
fi

cwd=$PWD;
#mkdir -p $DIR_OUT

echo "Changing file names:"
echo "folder --" $DIR;
echo "using --" $PARAM;
cd $DIR

i=1;
while read -r line; do 
    read -r "ID" "condition"  <<< "$line"
    if [[ $i -gt 1 ]]; then
	#echo $ID;
	files=( $(ls | grep $ID) )
	
	if [ ${#files[@]} -ge 1 ]; then ## one for .bam and the other for .bam.bai
	    if [ ${#files[@]} -gt 2 ]; then
		echo "More than 2 FILES found for " $ID "--" "${files[@]}";
	    else
		for old in "${files[@]}"; do 
		    extension=${old##*.}
		    # add bam. for bai extension
		    if [ "$extension" == "bai" ]; then
			extension=bam.${extension}
		    fi
		    
		    new=${condition}_${ID}.${extension};
		    if [ ! -e "$new" ]; then
			echo "file name from-to : "  $old "--" $new
			#echo "--"
			mv "$old" "$new"
		    else
			echo "file existed already --", $new 
		    fi
	        done
	    fi
	else
	    echo "NO FILES found -- " $ID;
	fi
    fi
    i=$((i + 1));
    
done < "$PARAM"

cd $cwd;
