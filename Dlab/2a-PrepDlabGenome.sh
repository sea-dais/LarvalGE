# Chromosome-level genomes of scleractinian corals: gene prediction and functional annotation
# Sebastian Metz

pip install zenodo_get

# Downloads https://zenodo.org/records/19135866
zenodo_get 10.5281/zenodo.19135866 -g "*coral-genomes-annotation*"

ls -lh coral-genomes-annotation-v1.0.0.zip   # confirm ~2.1G
unzip -t coral-genomes-annotation-v1.0.0.zip # integrity test — should say "No errors detected"

# Unzip only DLAB
unzip coral-genomes-annotation-v1.0.0.zip "sebametz-coral-genomes-annotation-5d18908/results/jaDipLaby1_Diploria_labyrinthiformis/*"

mv jaDipLaby1_Diploria_labyrinthiformis dlab_genome
# Readme says braker.gtf.gz is the one to use 

# genome: 
datasets download genome accession GCA_965282425.1 --include gff3,rna,cds,protein,genome,seq-report --filename dlab_genome.zip

idev -p pvc  -N 1 -n 1 -t 02:00:00 -A IBN21018
conda activate STAR

STAR --runMode genomeGenerate \
     --genomeDir dlab_star \
     --genomeFastaFiles GCA_965282425.1_jaDipLaby1.1_genomic.fna \
     --sjdbGTFfile braker.gtf \
     --sjdbOverhang 100 \
     --genomeSAindexNbases 13 \
     --runThreadN 8

# VERIFY before aligning — this is the check that matters
wc -l dlab_star/geneInfo.tab
head dlab_star/geneInfo.tab

# Check STAR built splice junctions: 
wc -l dlab_star/sjdbList.out.tab







########## check compatibility
# extract sequence names and lengths from genome
grep '^>' GCA_965282425.1_jaDipLaby1.1_genomic.fna | sed 's/^>//; s/ .*//' | sort > genome_seqs.txt
head genome_seqs.txt

# extract sequence names from gtf
grep -v '^#' braker.gtf | cut -f1 | sort -u > gtf_seqs.txt

# names in GTF but NOT in genome — these break compatibility
comm -23 gtf_seqs.txt <(cut -f1 genome_seqs.txt)