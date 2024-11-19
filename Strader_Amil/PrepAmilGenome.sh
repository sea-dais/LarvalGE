### STAR INDEX the Reference Genome
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
     --sjdbOverhang 24 #minimum read size -1 = 24


######
make_clusters2isogroups.pl Amil.all.maker.transcripts.fasta > Amil_clusters2isogroups.tab

#---------------------------------------
# download and format reference transcriptome:
# NOTE: this pipeline assumes that the reference is transcriptome - either made de novo, 
# or generated in silico based on annotated genome. We recommend this way of analysis 
# to save computing power.

cd /path/to/reference/data/
# download the transcriptome data using wget or scp, unpack it (tar vxf , unzip, etc)
# creating bowtie2 index for your transcriptome:
bowtie2-build transcriptome.fasta transcriptome.fasta 
cd /where/reads/are/

#---------------------------------------
# download and format reference transcriptome:
# NOTE: this pipeline assumes that the reference is transcriptome - either made de novo, 
# or generated in silico based on annotated genome. We recommend this way of analysis 
# to save computing power.

# cd /path/to/reference/data/
# download the transcriptome data using wget or scp, unpack it (tar vxf , unzip, etc)
# creating bowtie2 index for your transcriptome:
# bowtie2-build transcriptome.fasta transcriptome.fasta 

WORK="/work/08717/dmflores/ls6"
export GENOME_FASTA=$WORK/db/Amil_v2.01_annotated/Amil.all.maker.transcripts.fasta
export GENOME_DICT=$WORK/db/Amil_v2.01_annotated

# indexing genome for bowtie2 mapper
conda activate genomeenv
bowtie2-build $GENOME_FASTA $GENOME_FASTA

samtools faidx $GENOME_FASTA