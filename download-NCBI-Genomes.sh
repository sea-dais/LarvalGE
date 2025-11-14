conda create -n ncbi_datasets

conda activate ncbi_datasets
conda install -c conda-forge ncbi-datasets-cli

datasets download genome accession GCA_043250805.1 --include gff3,rna,cds,protein,genome,seq-report 

datasets download genome accession GCA_965282425.1 --include gff3,rna,cds,protein,genome,seq-report --filename dlab_genome.zip

