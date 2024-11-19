## MAP
cd /scratch/08717/dmflores/LarvalGE/AMIL/TrimmedFQ

export REF="$WORK/db/Amil_v2.01_annotated/Amil.all.maker.transcripts.fasta"

tagseq_bowtie2map.pl "fastq$" $REF  > maps

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu


conda activate genomeenv
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate" maps.e2067758  > Amil_LarvalGE_algnmt_Nov19.txt

#On Local Computer
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/AMIL/TrimmedFQ/Amil_LarvalGE_algnmt_Nov19.txt ./Amil_BowtieAlignment.txt