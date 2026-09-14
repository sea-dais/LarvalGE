cd $SCRATCH/LarvalGE/OFAV  
mkdir -p aligned logs

> star.cmds
for F in TrimmedFQ/*.trim.fastq; do
  base=$(basename "$F" .trim.fastq)
  echo "STAR --runMode alignReads --genomeDir $SCRATCH/OfavGenome/ofav_star --readFilesIn $F --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20 --runThreadN 28 --outFileNamePrefix aligned/${base}_" >> star.cmds
done
wc -l star.cmds     # should equal your CNAT sample count

# generate slurm script
mkjob.sh -n star -j star.cmds -q pvc -c 28 -e STAR
sbatch star.slurm

########## also align 2021 samples 
> star21.cmds
for F in ofav2021/*.trim.fastq; do
  base=$(basename "$F" .trim.fastq)
  echo "STAR --runMode alignReads --genomeDir $SCRATCH/OfavGenome/ofav_star --readFilesIn $F --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20 --runThreadN 28 --outFileNamePrefix aligned2021/${base}_" >> star21.cmds
done
wc -l star21.cmds     # should equal your CNAT sample count

# generate slurm script
mkjob.sh -n star21 -j star21.cmds -q spr -c 28 -e STAR
sbatch star21.slurm

# alignment qc
multiqc ./aligned -n star_qc_report -o ./qc
# alignment qc
multiqc ./aligned2021 -n star_qc_report -o ./qc