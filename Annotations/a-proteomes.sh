# version + database each was run with (in the header comments)
zcat -f dlab_genome/jaDipLaby1.emapper.annotations.gz | grep '^##' | head
## Mon Aug 18 22:55:00 2025
## emapper-2.1.12
## /usr/local/bin/emapper.py --override --data_dir /lustre/scratch122/tol/resources/eggnog --cpu 22 --itype proteins -i jaDipLaby1_Diploria_labyrinthiformis/BRAKER3/braker.aa -o jaDipLaby1_Diploria_labyrinthiformis/jaDipLaby1_annotation --decorate_gff jaDipLaby1_Diploria_labyrinthiformis/jaDipLaby1.gff --decorate_gff_ID_field ID
##
## 23123 queries scanned
## Total time (seconds): 505.98747181892395
## Rate: 45.70 q/s
grep '^##' amil_genome/Amillepora_euk.emapper.annotations | head
grep '^#' amil_genome/Amillepora_euk.emapper.annotations | head
grep '^#' amil_genome/Amillepora_euk.emapper.annotations | head
# emapper version: emapper-1.0.3 emapper DB: 4.5.1
# command: ./emapper.py  -i ../Amillepora.proteins.fa --output Amillepora_euk -d euk --usemem --cpu 60
# time: Tue Oct  2 21:05:37 2018
#query_name     seed_eggNOG_ortholog    seed_ortholog_evalue    seed_ortholog_score     predicted_gene_name GO_terms        KEGG_KOs        BiGG_reactions  Annotation_tax_scope    OGsbestOG|evalue|score      COG cat eggNOG annot
# 23160 queries scanned
# Total time (seconds): 5230.30196118
# Rate: 4.43 q/s


# do the protein IDs match what you used in OrthoFinder / WGCNA?
zcat -f dlab_genome/jaDipLaby1.emapper.annotations.gz | grep -v '^#' | cut -f1 | head -3
grep -v '^#' amil_genome/Amillepora_euk.emapper.annotations | cut -f1 | head -3

# what is the cnat file?
head -3 cnat_genome/cnat_annot.tsv

mkdir -p $SCRATCH/proteomes

# wait check what i used for orthofinder: 
OF=$(pwd)/orthofinder/proteins

for pair in amil:Amil.fa cnat:Cnat.fa dlab:Dlab.fa; do
  sp=${pair%%:*}; f=$OF/${pair##*:}
  echo "== $sp =="
  grep '^>' $f | head -2
  grep '^>' $SCRATCH/proteomes/${sp}_clean.faa | head -2
  echo "shared:      $(comm -12 <(grep '^>' $f | cut -d' ' -f1 | sort) <(grep '^>' $SCRATCH/proteomes/${sp}_clean.faa | cut -d' ' -f1 | sort) | wc -l)"
  echo "orthofinder: $(grep -c '^>' $f)"
  echo "genome dir:  $(grep -c '^>' $SCRATCH/proteomes/${sp}_clean.faa)"
done


OF=$WORK/orthofinder/proteins     # <-- EDIT: use the absolute path
mkdir -p $SCRATCH/proteomes
for sp in Ofav Amil Cnat Dlab; do
  lc=${sp,,}
  sed '/^>/!s/\*//g' $OF/${sp}.fa > $SCRATCH/proteomes/${lc}_clean.faa
  echo "$lc: $(grep -c '^>' $SCRATCH/proteomes/${lc}_clean.faa) proteins"
done
# expect 25929, 28188, 29090, 24564