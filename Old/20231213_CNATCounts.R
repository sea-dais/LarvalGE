#Make seq2iso.tab
cd /scratch/08717/dmflores/KBeavers/SCTLD-Transmission-Experiment-USVI/Transcriptomes
awk -F'\t' -v OFS='\t' '{print $2, $1}' annotated_cnat_reference.txt > cnat_tx2gene.tab

##------START Counts
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/quants
#Each sample has its own directory 
idev 2:00:00
conda activate OneMap
R
BiocManager::install("tximport")

dir<- "/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT"

#Need CNAT_quantlist.txt
samples <- read.table(file.path(dir, "CNAT_quantlist.txt"), header = FALSE)

files <- file.path(dir, "quants", samples$V1, "quant.sf")
names(files) <- paste0(samples$V1)
all(file.exists(files))

ref<-"/scratch/08717/dmflores/KBeavers/SCTLD-Transmission-Experiment-USVI/Transcriptomes/"
tx2gene <- read.table(file.path(ref, "cnat_tx2gene.tab"), header = FALSE)

library(tximport)
library(readr)

txi <- tximport(files, type = "salmon", tx2gene = tx2gene)
names(txi)

head(txi$counts)

write.table(txi, file= "Cnat_allcounts.txt", quote = F, sep = "\t", row.names = T, col.names = T)

#On Local Computer
cd /Users/daisyflores/Desktop/CNAT
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/quants/\*txt .
