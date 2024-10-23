### STAR INDEX the Reference Genome
idev
conda activate cufflinks
gffread -T Amil.coding.gff3 -o amil.gtf

conda activate STAR
STAR --runThreadN 8 \
     --runMode genomeGenerate \
     --genomeDir $WORK/db/amil/star_index \
     --genomeFastaFiles $WORK/db/amilV2_chroms.fasta  \
     --sjdbGTFfile $WORK/db/amil.gtf \
     --sjdbOverhang 100

## Edit StarAlignment.sh 
conda activate STAR
sbatch Amil-STARalignment.sh

cd $SCRATCH/LarvalGE/AMIL/STAR_Output
echo "conda run -n qc multiqc *Log.final.out" > STARmultiqc

ls6_launcher_creator.py -q vm-small -j STARmultiqc -n STARmultiqc -t 2:00:00 -a IBN21018 -e dmflores@utexas.edu

conda activate qc 
sbatch STARmultiqc.slurm

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/AMIL/STAR_Output/multiqc_report.html ./multiqcReport2.html

