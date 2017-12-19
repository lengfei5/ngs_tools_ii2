query="bait_chr17_Oc4_G11_reporter_reverse.fa"
subj="Oct4_reporter_sequence.fa"
out="out_test.txt"
blastn -query $subj -strand plus -out $out -subject $query -outfmt 7 -html