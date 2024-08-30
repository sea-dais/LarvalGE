conda create -n Eggnog
conda install -c bioconda eggnog-mapper

idev 2:00:00

download_eggnog_data.py 

emapper.py -i Pseudodiploria_strigosa_peptides_100.final.clstr.faa --cpu 24 -o Pstr_protein.out
emapper.py -m diamond --itype CDS -i Pseudodiploria_strigosa_cds_100.final.clstr.fna -o Pstr_cdna.out --cpu 24