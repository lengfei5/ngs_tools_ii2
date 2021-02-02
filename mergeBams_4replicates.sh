#############
# This script is to merge bam files
# requiring arguments:
# input (directory for bams files),
# output directory (optional if different from the directory of initial bams),
# a text file that specifies according what to merge 
# (same sample ID or replicates, i.e., same condition) and file names after merging. 
# updated for slurm
############
while getopts ":hD:O:f:tr" opts; do
    case "$opts" in
        "h")
            echo "This script is to merge bam files requiring arguments: "
	    echo "-D (input directory for bams files) "
            echo "-O (output directory optional if different from the directory of initial bams) "
            echo "-f (a text file for the sample infos in the form of design matrix: \
                      two columns, sampleID and Conditions)"
            echo "-t (to merge technical replicates with same sample ID)" 
	    echo "-r (to merge biological replicates, i.e., same condition)." 
	    echo "....................";
            echo "Usage:"
            echo "$0 -D alignments/BAMs_All -O BAMs_merged -f design_matrix.txt -t (or -r)"
            exit 0
            ;;
        "D")
            DIR_Bams="$OPTARG"
            ;;
	"O")
	    DIR_OUT="$OPTARG";
	    ;;
	"f")
	    params="$OPTARG";
	    ;;
	"t")
	    technicalRep="TRUE"
	    ;;
	"r")
	    biologicalRep="TRUE"
	    ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option -DOf "
	    exit 1;
            ;;
    esac
done

if [ -z "$DIR_OUT" ]; then 
    DIR_OUT=$DIR_Bams;
fi
merge_techRep="FALSE";
merge_bioRep="FALSE";

if [ "$technicalRep" == "TRUE" ]; then
    if [ -z "$biologicalRep" ]; then
	merge_techRep="TRUE";
    else
	echo "make a choice -- to merge technical or biological replicates"
	exit 1;
    fi
fi    
if [ "$biologicalRep" == "TRUE" ]; then
    if [ -z "$technicalRep" ]; then
	merge_bioRep="TRUE";
    else
	echo "make a choice -- to merge technical or biological replicates"
	exit 1;
    fi
fi

# internal params
nb_cores=8
jobName='mergeRep'

cwd=$PWD;
DIR_backup=${DIR_OUT}/before_merging
dir_logs=${cwd}/logs

mkdir -p $DIR_OUT
mkdir -p $DIR_backup
mkdir -p $dir_logs

# loop over the design matrix file
if [ "$merge_techRep" == "TRUE" ]; then
    echo '------'
    echo "-- Merge Technical Replicates --"
    echo '------'
    
    tomerge=(`cat $params | cut -f1 | sort -u |grep -v sampleID`)
    #echo $tomerge
else
    echo "-- Merge Biological Replicates --"
    #echo "files to be merged "
    tomerge=(`cat $params | cut -f2 | sort -u |grep -v fileName|grep -v condition`)
    #echo $tomerge
fi

for selection in "${tomerge[@]}"; do
    # find the bam to merge
    echo $selection 
    old=($(ls ${DIR_Bams}/*.bam | grep "$selection"));
    #echo $old
    # the name for merged file
    if [ "$merge_techRep" == "TRUE" ]; then
	cond=`cat $params | grep $selection |cut -f2|sort -u`
	if [[ ${#cond[@]} -eq 1 ]]; then
	    out=${cond}_${selection}
	else
	    echo "ERROR-- > 1 conditions found !!! "
	fi
    else
	id=`cat $params|grep $selection |cut -f1|sort -u| tr '\n' '.'`
	out=${selection}_${id}_merged
    fi
    
    script=${dir_logs}/${selection}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=240
#SBATCH --mem=32G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${script}.out
#SBATCH -e ${script}.err
#SBATCH --job-name $jobName

ml load samtools/1.10-foss-2018b

EOF
    
    ## if >= 2 bams found
    if [[ ${#old[@]} -gt 1 ]]; then
	if [ ! -e "${DIR_OUT}/${out}.bam" ] ; then
	    echo ${#old[@]} "files found --" $selection  "-- merged file name:" $out
	    
	    cat <<EOF >> $script
samtools merge -@ $nb_cores ${DIR_OUT}/${out}_unsorted.bam ${old[@]}
samtools sort -@ $nb_cores -o $DIR_OUT/${out}.bam $DIR_OUT/${out}_unsorted.bam
samtools index -c -m 14 ${DIR_OUT}/${out}.bam
mv $DIR_OUT/${out}_unsorted.bam
mv ${old[@]} $DIR_backup

EOF

	    #cat $script;
	    sbatch $script
	    
	fi;
    fi
    
    ## only 1 bam found
    if [[ ${#old[@]} -eq 1 ]] && [ "$merge_bioRep" == "TRUE" ]; then
	echo ${#old[@]} "file found --" $selection  "-- merged file name:" $out
	if [ ! -e "${DIR_OUT}/${out}.bam" ]; then
	   cat <<EOF >> $script
cp ${old[@]} ${DIR_OUT}/${out}.bam
samtools index -c -m 14 ${DIR_OUT}/${out}.bam
#mv ${old[@]} $DIR_backup;

EOF

	   #cat $script;
	   sbatch $script
	   
	fi;
    fi
    
    #break;
    
done


