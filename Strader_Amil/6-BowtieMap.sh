## MAP
cd /scratch/08717/dmflores/Amillepora/TrimmedFQ

export REF="$WORK/db/amilV2_chroms.fasta"

>maps
for F in `ls *.fastq`; do
echo "bowtie2 --no-unal -x $REF -U $F -S ${F/.fastq/}.sam">>maps
done

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano maps.slurm

conda activate genomeenv
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate" maps.e1989117 > Amil_algnmt_rates.txt

conda activate genomeenv
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate" maps.e1915964 > Amil_algnmt_rates.txt

### Extra QC
#Paste following
nano multiqc
multiqc maps.e1915964

ls6_launcher_creator.py -j multiqc -n multiqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano multiqc.slurm

conda activate qc
sbatch multiqc.slurm
#On Local Computer
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/Amillepora/TrimmedFQ/\*html .