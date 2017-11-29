
#cat $1 |while read L; do  echo $L; read L; echo "$L" | rev | tr "ATGC" "TACG" ; done
#case  in
if [ ! -z "$1" ]; then
    cat "$1" | tr "[ATGCatgc]" "[TACGtacg]" | rev;
else
    echo ""
    echo "usage: rev_comp_seq DNASEQUENCE"
    echo ""
fi   
    