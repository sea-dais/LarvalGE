# quick look format is proper
grep -P "\texon\t" GCF_002042975.1_ofav_dov_v1_genomic2_genesannotated.gtf | head
awk '$3=="gene"' GCF_002042975.1_ofav_dov_v1_genomic2_genesannotated.gtf | head

# genome size
grep -v '^>' GCF_002042975.1_ofav_dov_v1_genomic.fna | tr -d '\n' | wc -c
## 485,548,939 bp ≈ 486 Mb
#log2(485,548,939) ≈ 28.86
#28.86 / 2 − 1 ≈ 13.42
#floor(13.42) = 13
#min(14, 13) = 13


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
