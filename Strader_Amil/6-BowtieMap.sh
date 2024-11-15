## MAP
cd /scratch/08717/dmflores/LarvalGE/AMIL/TrimmedFQ

export REF="$WORK/db/amilV2_chroms.fasta"

>maps
for F in `ls *.fastq`; do
echo "bowtie2 --no-unal -x $REF -U $F -S ${F/.fastq/}.sam">>maps
done

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu


conda activate genomeenv
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate" maps.e2061460 > Amil_LarvalGE_algnmt_Nov14.txt

#On Local Computer
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/AMIL/TrimmedFQ/Amil_LarvalGE_algnmt_Nov14.txt ./Amil_BowtieAlignment.txt