# Create a new environment with Python 3.8
conda create -n orthofinder_env python=3.9
conda activate orthofinder_env

# Install orthofinder and dependencies
conda install -c bioconda orthofinder
conda install bioconda::bioawk

mkdir -p proteins && cd proteins
base=https://media.githubusercontent.com/media/sebepedroslab/oculina-coral-sc-atlas/master/data/reference
for sp in Nvec Spis Ocupat Amil Hvul ; do
  curl -L -o ${sp}_long.pep.fasta ${base}/${sp}_long.pep.fasta
done
ls -lh    # should be several MB each, not ~133 bytes
head -c 300 Nvec_long.pep.fasta

# check for stop codons: 
for f in *_long.pep.fasta ; do
  echo "$f: $(grep -c '>' $f) seqs, $(grep -v '>' $f | grep -c '\.') lines with '.'"
done

# clean up 
for sp in Nvec Spis Ocupat Amil Hvul ; do
  bioawk -c fastx '{ sub(/\.$/, "", $seq); gsub(/\./, "X", $seq); print ">"$name"\n"$seq }' \
    ${sp}_long.pep.fasta > ${sp}.fa
done
grep -v '>' Amil.fa | grep -c '\.'    # should be 0
mkdir -p ../originals && mv *_long.pep.fasta ../originals/

## Ofav 
# Map protein to its gene with ncbi GFF
awk -F'\t' '$3=="CDS" {
  p=""; g="";
  if (match($9,/protein_id=[^;]+/)) p=substr($9,RSTART+11,RLENGTH-11);
  if (match($9,/;gene=[^;]+/))      g=substr($9,RSTART+6,RLENGTH-6);
  if (p!="" && g!="") print p"\t"g }' \
  GCF_002042975.1_ofav_dov_v1_genomic.gff | sort -u > Ofav_prot2gene.tsv
head -3 Ofav_prot2gene.tsv

# Keep the longest protein per gene, with the fene ID as the header
bioawk -c fastx '{ print $name"\t"length($seq) }' Ofav_proteins.fa > Ofav_protlen.tsv

awk 'NR==FNR { g[$1]=$2; next } ($1 in g) { print g[$1]"\t"$1"\t"$2 }' Ofav_prot2gene.tsv Ofav_protlen.tsv \
  | sort -k1,1 -k3,3nr | awk '!seen[$1]++' > Ofav_longest.tsv

awk 'NR==FNR { keep[$2]=$1; next }
     /^>/ { id=substr($1,2); p=(id in keep); if (p) print ">Ofav_"keep[id]; next }
     p' Ofav_longest.tsv Ofav_proteins.fa > $WORK/orthofinder/proteins/Ofav.fa

grep -c ">" $WORK/orthofinder/proteins/Ofav.fa    # one per protein-coding gene
wc -l Ofav_longest.tsv                           # should match

# CNAT 

cd cnat_genome
zcat Colpophyllia_natans.proteins.fa.gz | head -2 | cut -c1-100
zcat Colpophyllia_natans.proteins.fa.gz | grep -c ">"                                   # transcripts
zcat Colpophyllia_natans.proteins.fa.gz | grep ">" | cut -d' ' -f1 | sed 's/>//; s/-T[0-9]*$//' | sort -u | wc -l   # genes
zcat Colpophyllia_natans.proteins.fa.gz | grep -v ">" | grep -c '[*.]'                  # stop codons

# build cnat.fa longest protein per gene
bioawk -c fastx '{ g=$name; sub(/-T[0-9]+$/, "", g);
                   s=$seq; sub(/[*.]$/, "", s); gsub(/[*.]/, "X", s);
                   print g"\t"$name"\t"length(s)"\t"s }' Colpophyllia_natans.proteins.fa.gz \
  | sort -t$'\t' -k1,1 -k3,3nr \
  | awk -F'\t' '!seen[$1]++' > Cnat_longest_full.tsv

cut -f1-3 Cnat_longest_full.tsv > Cnat_longest.tsv
awk -F'\t' '{ print ">Cnat_"$1"\n"$4 }' Cnat_longest_full.tsv > $WORK/orthofinder/proteins/Cnat.fa
rm Cnat_longest_full.tsv

grep -c ">" $WORK/orthofinder/proteins/Cnat.fa   # should equal the gene count from step 1
head -3 Cnat_longest.tsv

cprot <- read.delim("Cnat_longest.tsv", header = FALSE, col.names = c("gene", "protein", "len"))
mean(rownames(data) %in% cprot$gene)                # expect close to 1
head(rownames(data)[!rownames(data) %in% cprot$gene])


# CNAT
cd dlab_genome
zcat braker.aa.gz | head -2 | cut -c1-100
zcat braker.aa.gz | grep -c ">"                                                    # transcripts
zcat braker.aa.gz | grep ">" | cut -d' ' -f1 | sed 's/>//; s/\.t[0-9]*$//' | sort -u | wc -l   # genes
zcat braker.aa.gz | grep -v ">" | grep -c '[*.]'                                   # stop codons


# build dlab.fa
bioawk -c fastx '{ g=$name; sub(/\.t[0-9]+$/, "", g);
                   s=$seq; sub(/[*.]$/, "", s); gsub(/[*.]/, "X", s);
                   print g"\t"$name"\t"length(s)"\t"s }' braker.aa.gz \
  | sort -t$'\t' -k1,1 -k3,3nr \
  | awk -F'\t' '!seen[$1]++' > Dlab_longest_full.tsv

cut -f1-3 Dlab_longest_full.tsv > Dlab_longest.tsv
awk -F'\t' '{ print ">Dlab_"$1"\n"$4 }' Dlab_longest_full.tsv > $WORK/orthofinder/proteins/Dlab.fa
rm Dlab_longest_full.tsv

grep -c ">" $WORK/orthofinder/proteins/Dlab.fa   # should equal the gene count from step 1

dprot <- read.delim("Dlab_longest.tsv", header = FALSE, col.names = c("gene", "protein", "len"))
mean(rownames(data) %in% dprot$gene)   # expect close to 1 (BRAKER predicts only protein-coding genes)


### Final 
cd $WORK/orthofinder/proteins/

grep -c ">" *.fa
grep -h ">" *.fa | cut -d' ' -f1 | sort | uniq -d | head    # should print nothing

# remove empty sequences. 

for f in *.fa *.faa *.fasta; do
  [ -e "$f" ] || continue
  n=$(awk '/^>/{if(h && !s) c++; h=1; s=0; next} NF{s=1} END{if(h && !s) c++; print c+0}' "$f")
  echo "$f: $n empty sequences"
done

cp Amil.fa Amil.fa.bak
awk 'BEGIN{RS=">"; ORS=""} NR>1 {n=split($0,a,"\n"); seq=""; for(i=2;i<=n;i++) seq=seq a[i]; gsub(/[ \t\r]/,"",seq); if(length(seq)>0) print ">"$0}' Amil.fa.bak | grep -v '^$' > Amil.fa