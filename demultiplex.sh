#####
## this script is to demultiplex the bam files from vbcf
####
jobName='demultiplex'

DIR_cwd=`pwd`
DIR_FC=$PWD/ngs_raw/RAWs
DIR_OUT=$PWD/ngs_raw/BAMs
dir_logs=$PWD/logs

mkdir -p $DIR_OUT;
mkdir -p $dir_logs;
cd $DIR_FC;

## demultiplex raw data
for RAW in ${DIR_FC}/*.bam; do

    echo $RAW
    FILENAME="$(basename $RAW)";
    fname=${FILENAME%.*}
    fname=${fname/\#/\_}
    echo "$file" $fname
    
    PREFIX=$(basename $RAW .bam)
    DIRNAME="${DIR_OUT}/${PREFIX}_demultiplex"

    echo $DIRNAME
    
    mkdir -p $DIRNAME
        
    script=${fname}_${jobName}.sh
    
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=6
#SBATCH --time=4:00:00
#SBATCH --mem=20G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $dir_logs/${fname}.out
#SBATCH -e $dir_logs/${fname}.err
#SBATCH --job-name $jobName

ml load java/11.0.2
export MODULEPATH=/groups/bioinfo/shared/public/modulescbe:$MODULEPATH
ml load bioinfo.grp/vbcf_demultiplexer/0.8

java -jar $ROOTDEMUX/demultiplexer.jar getbarcodesanddemultiplex --prefix ${DIRNAME}/${PREFIX} --inpath $RAW --tofastq

EOF
    
cat $script;

sbatch $script
#break;    

done

cd $DIR_cwd
