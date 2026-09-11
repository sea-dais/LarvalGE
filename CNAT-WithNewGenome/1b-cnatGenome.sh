pip install zenodo_get

# Downloads every file in the record, verifies md5, into current dir
zenodo_get 10.5281/zenodo.13323697

ls -lh cnat_dcyl_ssid_genomes-v1.0.1.zip   # confirm ~1.07G
unzip -t cnat_dcyl_ssid_genomes-v1.0.1.zip # integrity test — should say "No errors detected"

unzip cnat_dcyl_ssid_genomes-v1.0.1.zip

# Find the C. natans assembly and annotation
find . -iname '*cnat*' -o -iname '*colpophyllia*'


cd mistergroot-cnat_dcyl_ssid_genomes-4e36afc/resources

# Which scaffold names does the annotation actually use?
zcat Colpophyllia_natans.gff3.gz | grep -v '^#' | cut -f1 | sort -u | head

# What are the scaffold names in each FASTA?
zcat Colpophyllia_natans.scaffolds.0.fa.gz | grep '^>' | head
zcat Colpophyllia_natans.scaffolds.1.fa.gz | grep '^>' | head


# All contig IDs the annotation uses
zcat Colpophyllia_natans.gff3.gz | grep -v '^#' | cut -f1 | sort -u > gff_ids.txt
wc -l gff_ids.txt

# Contig IDs present if you combine BOTH fasta files
cat <(zcat Colpophyllia_natans.scaffolds.0.fa.gz | grep '^>') \
    <(zcat Colpophyllia_natans.scaffolds.1.fa.gz | grep '^>') \
  | sed 's/>//; s/ .*//' | sort -u > fasta_both_ids.txt
wc -l fasta_both_ids.txt

# GFF IDs missing from the COMBINED fasta (should be empty)
comm -23 gff_ids.txt fasta_both_ids.txt


# Concatenate both scaffold files into one genome FASTA
cat Colpophyllia_natans.scaffolds.0.fa.gz Colpophyllia_natans.scaffolds.1.fa.gz \
  > Colpophyllia_natans.genome.fa.gz
gunzip -k Colpophyllia_natans.genome.fa.gz     # -> Colpophyllia_natans.genome.fa

gunzip -k Colpophyllia_natans.gff3.gz          # -> Colpophyllia_natans.gff3

comm -23 \
  <(grep -v '^#' Colpophyllia_natans.gff3 | cut -f1 | sort -u) \
  <(grep '^>' Colpophyllia_natans.genome.fa | sed 's/>//; s/ .*//' | sort -u)

# inspect gff feature types: 
grep -v '^#' Colpophyllia_natans.gff3 | cut -f3 | sort | uniq -c
grep -v '^#' Colpophyllia_natans.gff3 | awk -F'\t' '$3=="exon"' | head -2

# Read length (look at the sequence line length)
cat $SCRATCH/LarvalGE/CNAT/A4-1_S227.trim.fastq | head -2
# e.g. if the seq line is 100 chars, sjdbOverhang = 99

# Genome size in bp
grep -v '^>' Colpophyllia_natans.genome.fa | tr -d '\n' | wc -c
#398942710