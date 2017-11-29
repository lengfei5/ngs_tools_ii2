module load blat
query="G11_sequence.fa"
DIR_genome="/groups/bell/jiwang/Genomes/Mouse/mm9_UCSC/Sequence/"
nb_cores=2;
cwd=`pwd`
OUT=$PWD/res_blat
mkdir -p $OUT
mkdir -p $PWD/logs

for chr in `ls $DIR_genome/chr*.fa`; do
    chrN=`basename $chr`
    out=${chrN%%.fa}_${query%%.fa}
    #blat $database $genome output.psl
    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N blat "module load blat; blat $chr $query ${OUT}/${out}.psl;"
done