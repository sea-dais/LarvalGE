cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB
#---------------------------------------
# mapping reads to transcriptome

# cd where the trimmed read files are (extension "trim")
tagseq_bowtie2map.pl "trim$" /work/08717/dmflores/ls6/Pstr/Pseudodiploria_strigosa_cds_100.final.clstr.fna  > maps
# execute all the commands in 'maps', record screen output in some file

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano maps.slurm
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate" maps.e1295178 > DLAB_alignment_rates.txt

nano multiqc
#Paste following
multiqc .

ls6_launcher_creator.py -j multiqc -n multiqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano multiqc.slurm

conda activate qc
sbatch multiqc.slurm
#On Local Computer
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB/multiqc_report.html .