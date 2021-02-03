###########
#
# blast the nucleotide sequence again the genome
# 
##########
ml load ncbi-blast+/2.10.0

query=/groups/tanaka/People/current/jiwang/projects/positional_memory/AkaneToJingkuiShareFiles/HoxD_Candidates_axCNEs/Axolotl_HoxD_CNEs_NEW/axCS15a.fa

subj=/groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexG_v6.DD.corrected.round2.chr_mtDNA.NCBI.AJ584639.1.fa

out="out_test.txt"
blastn -query $subj -strand plus -out $out -subject $query -outfmt 7 -html

# Sergej blastn code
for FILE in $(ls Axolotl_HoxD_CNEs_NEW/*.fa); do echo $FILE; blastn -query $FILE -db /groups/tanaka/Projects/axolotl-omics.org/data/indices/blast/genome/AmexG_v6.0.DD/AmexG_v6.DD -max_target_seqs 10 -outfmt "6 sseqid sstart send qseqid " > ${FILE}.blastout.bed; done
