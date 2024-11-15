#Transcriptomes From Kelsey Beavers
cd /scratch/08717/dmflores/KBeavers/SCTLD-Transmission-Experiment-USVI/Transcriptomes
git clone https://github.com/kbeavz/SCTLD-Transmission-Experiment-USVI.git

##---Salmon
conda create -n salmon salmon
conda activate salmon 

##---Index transcriptome
salmon index -t Pstr_transcriptome.tar.gz -i $REF_Index --kmerLen 25
#-kmerSize default is 31, change to smaller; minimum read size is 25. 

export REF_Index=$SCRATCH/KBeavers/data/Pstr/Pstr_index
