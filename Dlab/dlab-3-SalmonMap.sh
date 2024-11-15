#__Previously
###Dlab-FastqFiles.sh
###Prep-PstrGenome.sh


## Make txt2gene.tab
cd /scratch/08717/dmflores/KBeavers/SCTLD-Transmission-Experiment-USVI/Transcriptomes
awk -F'\t' -v OFS='\t' '{print $2, $1}' annotated_pstr_reference.txt > pstr_tx2gene.tab

# From Prep-PstrGenome.sh
export REF_Index=$SCRATCH/KBeavers/data/Pstr/Pstr_index
##--- Map with Salmon
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB

>quant
for file in *fastq; do
base_name=$(echo "$file" | cut -d'_' -f1)
echo "salmon quant -i $REF_Index -l A -r ${file} -p 50 --fldMean 80 --validateMappings --minScoreFraction 0.50  -o quants/${base_name}_quant" >> quant
done 
# -l LibType Automatic 
# -r for Single read type input use -1 & -2 for paired reads
# -p Threads
#--fldMean Important for single end reads, Since the empirical fragment length distribution cannot be estimated from the mappings of single-end reads, the --fldMean allows the user to set the expected mean fragment length of the sequencing library.Retrieve info from GSAF Bioanalyzer data 

conda activate salmon 
ls6_launcher_creator.py -q development -j quant -n quant -t 2:00:00 -a IBN21018 -e dmflores@utexas.edu
nano quant.slurm

sbatch quant.slurm

##------
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB/quants
#Each sample has its own directory 
find . -maxdepth 1 -type d -exec basename {} \; > quantlist.txt


##------START Counts
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB/quants
#Each sample has its own directory 
idev -t 00:90:00
conda activate OneMap
R

BiocManager::install("tximport")
library(tximport)

dir<- "/scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB"
setwd(dir)
#Need DLAB_quantlist.txt
samples <- read.table(file.path(dir, "quantlist.txt"), header = FALSE)

files <- file.path(dir, "quants", samples$V1, "quant.sf")
names(files) <- paste0(samples$V1)
all(file.exists(files))

ref <- "/scratch/08717/dmflores/KBeavers/data/Pstr/"
tx2gene <- read.table(file.path(ref, "pstr_tx2gene.tab"), header = FALSE)

library(tximport)
library(readr)

txi <- tximport(files, type = "salmon", tx2gene = tx2gene)
names(txi)

head(txi$counts)
counts <- as.data.frame(txi$counts)

write.table(counts, file= "Dlab_allcounts.txt", quote = F, sep = "\t", row.names = T, col.names = T)

#On Local Computer
cd /Users/daisyflores/Desktop/Projects/LarvalGE/DLAB/data

LS6="dmflores@ls6.tacc.utexas.edu"
SCRATCH="/scratch/08717/dmflores"

scp $LS6:$SCRATCH/LarvalGE/TrimmedFQ//DLAB/Dlab_allcounts.txt .

