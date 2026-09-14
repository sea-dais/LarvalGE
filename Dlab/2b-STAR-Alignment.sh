cd $SCRATCH/LarvalGE/DLAB  
mkdir -p aligned logs

> star.cmds
for F in files/*.trim.fastq; do
  base=$(basename "$F" .trim.fastq)
  echo "STAR --runMode alignReads --genomeDir $SCRATCH/dlab_genome/dlab_star --readFilesIn $F --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20 --runThreadN 28 --outFileNamePrefix aligned/${base}_" >> star.cmds
done
wc -l star.cmds     # should equal your CNAT sample count

# generate slurm script
mkjob.sh -n star -j star.cmds -q pvc -c 28 -e STAR
sbatch star.slurm

# alignment qc
multiqc ./aligned -n star_qc_report -o ./qc