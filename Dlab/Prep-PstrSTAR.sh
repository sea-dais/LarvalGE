### STAR INDEX the Reference Genome

#Download P.strigosa genome from http://comparative.reefgenomics.org/datasets.html
Pseudodiploria_strigosa_cds_100.final.clstr.fna
Pseudodiploria_strigosa.annot.tsv
Pseudodiploria_strigosa_peptides_100.final.clstr.faa

idev

conda create -n ncbi_datasets
conda activate ncbi_datasets
conda install -c conda-forge ncbi-datasets-cli

datasets download genome accession GCF_013753865.1 --filename AmilGenome.zip --include gtf,gff3,rna,cds,protein,genome,seq-report

## Don't need the following lines if you already download gtf from ncbi
#conda activate cufflinks
#gffread -T Amil.coding.gff3 -o amil.gtf

conda activate STAR
STAR --runThreadN 8 \
     --runMode genomeGenerate \
     --genomeDir $WORK/AmilGenome\
     --genomeFastaFiles $WORK/AmilGenome/Amil_v2.1_genomic.fna \
     --sjdbGTFfile $WORK/AmilGenome/Amil.gtf \
     --sjdbOverhang 80 #read size -1 = 80