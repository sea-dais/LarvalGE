cd $SCRATCH/LarvalGE/AMIL  
mkdir -p aligned logs

> star.cmds
for F in Amil_FastqFiles/*.fastq; do
  base=$(basename "$F" .fastq)
  echo "STAR --runMode alignReads --genomeDir $WORK/amil_genome/amil_star --readFilesIn $F --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20 --runThreadN 28 --outFileNamePrefix aligned/${base}_" >> star.cmds
done
wc -l star.cmds     # should equal your CNAT sample count

# generate slurm script
mkjob.sh -n star -j star.cmds -q pvc -c 28 -e STAR
sbatch star.slurm

# alignment qc
multiqc ./aligned -n star_qc_report -o ./qc
