###########
#
# blast the nucleotide sequence again the genome
# 
##########
ml load ncbi-blast+/2.10.0

#query=/groups/tanaka/People/current/jiwang/projects/positional_memory/AkaneToJingkuiShareFiles/HoxD_Candidates_axCNEs/Axolotl_HoxD_CNEs_NEW/axCS15a.fa

#db=/groups/tanaka/People/current/jiwang/Genomes/axolotl/indice_blast/AmexG_v6.0.DD/AmexG_v6.DD
db=/groups/tanaka/Databases/Blast/Am_genome/AmexG_v5.0/AMEX
subj=/groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexG_v6.DD.corrected.round2.chr_mtDNA.NCBI.AJ584639.1.fa

dir_input=$1
dir_out="$PWD/blast_out_ax5.0"
mkdir -p $dir_out

maxHit=10
nb_cores=6
#blastn -query $subj -strand plus -out $out -subject $query -outfmt 7 -html

# Sergej blastn code using db
for FILE in $(ls $dir_input/*.fa);
do
    echo $FILE;
    fname=`basename $FILE`
    blastn -query $FILE -db $db -max_target_seqs $maxHit -num_threads $nb_cores \
	   -out ${dir_out}/${fname}.blast.txt -outfmt 0 
    blastn -query $FILE -db $db -max_target_seqs $maxHit -num_threads $nb_cores \
	   -outfmt "6 sseqid sstart send qseqid " > ${dir_out}/${fname}.blastout.bed;
done
