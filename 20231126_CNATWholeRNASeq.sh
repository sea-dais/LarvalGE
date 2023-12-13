#Select CNAT experiments, send to SRA Run Selector, download Accession List 
https://www.ncbi.nlm.nih.gov/Traces/study/?uids=14150492%2C14150491%2C14150485%2C14150484%2C14150481&o=acc_s%3Ad# 
##On local computer
scp SRR_Acc_List.txt dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/CNAT

prefetch --option-file SRR_Acc_List.txt

## on TACC 
>fq-dump
for F in SRR*; do
echo "fasterq-dump $F --split-files --include-technical -O /scratch/08717/dmflores/CNAT/fastqfiles" >> fq-dump;
done

ls6_launcher_creator.py -j fq-dump -n fq-dump -t 2:00:00 -w 24 -a IBN21018 -e dmflores@utexas.edu

#change number of processes and number of nodes to in fq−dump.slurm file
sbatch fq-dump.slurm

