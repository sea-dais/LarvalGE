
REMOTE=dmflores@stampede3.tacc.utexas.edu:/work2/08717/dmflores/stampede3/orthofinder_8sp/

rsync -avP "$REMOTE/Results_combined" .

rsync -avP "$REMOTE/Results_combined/Phylogenetic_Hierarchical_Orthogroups" .
rsync -avP "$REMOTE/Results_combined/Gene_Duplication_Events/" .
rsync -avP "$REMOTE/Results_combined/Orthogroups/" .

grep ">" $WORK/orthofinder/proteins/Amil.fa | tail -3

awk -F'\t' '$3=="exon"' amil.gtf | head -2 | cut -f9