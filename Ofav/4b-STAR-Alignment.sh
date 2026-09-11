cd $SCRATCH/LarvalGE   # or wherever CNAT/ and star_index/ live
mkdir -p aligned logs

> star.cmds
for F in CNAT/*.trim.fastq; do
  base=$(basename "$F" .trim.fastq)
  echo "STAR --runMode alignReads --genomeDir $SCRATCH/cnat_genome/star_index --readFilesIn $F --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20 --runThreadN 4 --outFileNamePrefix aligned/${base}_" >> star.cmds
done
wc -l star.cmds     # should equal your CNAT sample count

# generate slurm script
mkjob.sh -n star -j star.cmds -c 4 -e STAR
sbatch star.slurm