##Getting started with A.millepora dataset
#
cd /scratch/08717/dmflores/LarvalGE
mkdir AMIL
cd /scratch/08717/dmflores/LarvalGE/AMIL

#stored in $HOME/bin/
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.0/sratoolkit.3.0.0-centos_linux64.tar.gz
tar xzvf sratoolkit.3.0.0-centos_linux64.tar.gz
vdb-config --interactive

# this will download the .sra files to ~/ncbi/public/sra/ (will create directory if not present)
# Use IDev
$HOME/bin/sratoolkit.3.0.0-centos_linux64/bin/prefetch --option-file StraderAmilAccessionList.txt
# Directories for each biosample. 338 files downloaded
ls -l | wc 
#use fasterq-dump
# Create and activate a new environment
conda create -n sra -c bioconda sra-tools -y
conda activate sra

for F in SRR*; do
fasterq-dump $F --concatenate-reads -p -O /scratch/08717/dmflores/LarvalGE/AMIL/Amil_FastqFiles
done
#fasterq-dump SRR1943813 --concatenate-reads --include-technical
#manual https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump

>fq-dump
for F in SRR*; do
echo "fasterq-dump $F --concatenate-reads -O /scratch/08717/dmflores/LarvalGE/AMIL/Amil_FastqFiles" >> fq-dump;
done

ls6_launcher_creator.py -j fq-dump -n fq-dump -t 2:00:00 -w 24 -a IBN21018 -e dmflores@utexas.edu
#change number of processes to 2 and number of nodes to 2 in fq-dump.slurm file 
sbatch fq-dump.slurm

ls -d SRR* > downloaded

## In case not all were downloaded, to figure out what you need to download compare list. 
## This command will show the lines in file1 that are not present in file2.
# comm -23 AmilAccessionList.txt downloaded > re-download