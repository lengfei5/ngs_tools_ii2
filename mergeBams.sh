#######
## This script is to merge bam files
#######
nb_cores=4;
DIR_Bams=$PWD/DATA/Bams_chipseq_thomas_modEncode
DIR_OUT=$PWD/Results/heatmaps/Bams_merged
cwd=$PWD;

#conditions="AN312_ 515D10_  515D10H3_ D10A8_ D10D8_ 924E12_ E12F01_"
factors="tbx H3K4me1 H3K4me2 H3K4me3 H3K9me3 H3K27me3 H3K27ac"

mkdir -p $DIR_OUT
mkdir -p $cwd/logs

#i=1;
cd $DIR_Bams;
for ss in $factors; 
do 
    #for cond in $conditions;
    #do 
    echo $ss #$cond
    
    old=($(ls *.bam | grep ${ss}));
    echo ${#old[@]}
	
    if [[ ${#old[@]} -gt 1 ]]; then
	#echo ${old[@]};
	
	out=${ss}
	#for rr in ${old[@]};
	#do 
	#    ids=`echo "$rr" | cut -d'_' -f3`
	#out=${out}_${ids};
	#    echo $ids
	#done
	out=${out}_merged;
	echo $out;
	    #echo here
	if [ ! -e "${DIR_OUT}/${out}.bam" ]; then
	    qsub -q public.q -o $cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N mergeBam "module load samtools/1.3.1; samtools merge ${DIR_OUT}/${out}_unsorted.bam ${old[@]}; samtools sort -o $DIR_OUT/${out}.bam $DIR_OUT/${out}_unsorted.bam; samtools index ${DIR_OUT}/${out}.bam; rm $DIR_OUT/${out}_unsorted.bam; "
	fi;
	
    elif [[ ${#old[@]} -eq 1 ]]; then
	#echo ${#old[@]};
	echo "why is here"
	out=${ss}_merged
	#ids=`echo "$old" | cut -d'_' -f3`
	#out=${cond}${ss}_${ids}_merged
	#echo ${old[@]};
	#echo $ids
	echo $out;
	if [ ! -e "${DIR_OUT}/${out}.bam" ]; then
	    qsub -q public.q -o $cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N mergeBam "cp ${old[@]} ${DIR_OUT}/${out}.bam; module load samtools/1.3.1; samtools index ${DIR_OUT}/${out}.bam; "
	fi;
    else
	echo "NOT FOUND Bam files for $ss and $cond "
    fi
    echo ">>>>>"
    #break;
done

cd $cwd;
