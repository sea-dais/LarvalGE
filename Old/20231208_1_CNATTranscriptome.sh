#Salmon
conda create -n salmon salmon
conda activate salmon 

#Transcriptomes From Kelsey Beavers
cd /scratch/08717/dmflores/KBeavers/SCTLD-Transmission-Experiment-USVI/Transcriptomes
git clone https://github.com/kbeavz/SCTLD-Transmission-Experiment-USVI.git

#Index transcriptome
salmon index -t Cnat_transcriptome.tar.gz -i Cnat_index

export REF_Index=$SCRATCH/KBeavers/SCTLD-Transmission-Experiment-USVI/Transcriptomes/Cnat_index

## CNAT Files
#20230926_1_CopyFiles from BaseSpace
#20231104_2_Trim.sh
#20231104_3_SplitbySpecies
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT
>quant
for file in *fastq; do
base_name=$(echo "$file" | cut -d'_' -f1)
echo "salmon quant -i $REF_Index -l A -r ${file} -p 50 --fldMean 371 --validateMappings -o quants/${base_name}_quant" >> quant
done 
# -l LibType Automatic 
# -r for Single read type input use -1 & -2 for paired reads
# -p Threads
#--fldMean Important for single end reads, Since the empirical fragment length distribution cannot be estimated from the mappings of single-end reads, the --fldMean allows the user to set the expected mean fragment length of the sequencing library.Retrieve info from GSAF Bioanalyzer data 

ls6_launcher_creator.py -q development -j quant -n quant -t 2:00:00 -a IBN21018 -e dmflores@utexas.edu
nano quant.slurm

sbatch quant.slurm

##------
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/quants
#Each sample has its own directory 
