# 1. Convert GFF3 -> GTF
conda activate ngs-tools
gffread Amil.coding.gff3 -T -o Amil.coding.gtf

# 2. VERIFY the GTF has gene_id on exon lines (do not skip this)
grep -P "\texon\t" Amil.coding.gtf | head -2

grep -P "\texon\t" Amil.coding.gtf | grep -o 'gene_id "[^"]*"' | sort -u | wc -l
grep -v '^#' Amil.coding.gff3 | awk -F'\t' '$3=="gene"' | wc -l

grep '>' Amil.v2.01.fasta | head -3
cut -f1 Amil.coding.gtf | sort -u | head -3
# 3. Rebuild into a FRESH directory with default tags (no --sjdbGTFtag* flags)
#. # genome size
grep -v '^>' Amil.v2.00.chrs.fasta | tr -d '\n' | wc -c
## 485,548,939 bp ≈ 486 Mb
#log2(485,548,939) ≈ 28.86
#28.86 / 2 − 1 ≈ 13.42
#floor(13.42) = 13
#min(14, 13) = 13

#. --genomeSAindexNbases is based on genome size
#. --sjdbOverhang 100 is default; change to read length -1 
STAR --runMode genomeGenerate \
  --genomeDir amil_star \
  --genomeFastaFiles Amil.v2.01.fasta \
  --sjdbGTFfile Amil.coding.gtf \
  --sjdbOverhang 44 \
  --genomeSAindexNbases 13 \
  --runThreadN 10

# 4. VERIFY before aligning — this is the check that matters
wc -l amil_star/geneInfo.tab
tail amil_star/geneInfo.tab

# Check STAR built splice junctions: 
wc -l amil_star/sjdbList.out.tab
head amil_star/sjdbInfo.tab

# quick look format is proper
grep -P "\texon\t" Amil.coding.gtf | head
awk '$3=="gene"' Amil.coding.gtf | head




idev -p pvc  -N 1 -n 1 -t 02:00:00 -A IBN21018
conda activate STAR

STAR --runMode genomeGenerate \
     --genomeDir ofav_star \
     --genomeFastaFiles GCF_002042975.1_ofav_dov_v1_genomic.fna \
     --sjdbGTFfile GCF_002042975.1_ofav_dov_v1_genomic2_genesannotated.gtf \
     --sjdbOverhang 100 \
     --genomeSAindexNbases 13 \
     --runThreadN 8

# VERIFY before aligning — this is the check that matters
wc -l ofav_star/geneInfo.tab
head ofav_star/geneInfo.tab

# Check STAR built splice junctions: 
wc -l ofav_star/sjdbList.out.tab
