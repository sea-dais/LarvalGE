###---STAR INDEX the Reference Genome
#Follow Prep AmilGenome.sh
#Change sjdbOverhang to the minimum read size -1 (in this case = 24)
#Will need to re-index genome if transcripts are different size 

##---Edit StarAlignment.sh 
#Make sure directory alias point to correct path where files are stored/will be stored
conda activate STAR
sbatch Amil-STARalignment.sh

##---Multiqc mapped reads
cd $SCRATCH/LarvalGE/AMIL/STAR_Output
echo "conda run -n qc multiqc *Log.final.out" > STARmultiqc

ls6_launcher_creator.py -q vm-small -j STARmultiqc -n STARmultiqc -t 2:00:00 -a IBN21018 -e dmflores@utexas.edu

conda activate qc 
sbatch STARmultiqc.slurm

## Copy html to local cpu to view
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/AMIL/STAR_Output/multiqc_report.html ./multiqcReport4.html

