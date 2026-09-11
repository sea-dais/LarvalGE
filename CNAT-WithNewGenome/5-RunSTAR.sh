### STAR INDEX the Reference Genome
idev -t 02:00:00
conda activate STAR

grep -v '^>' Colpophyllia_natans.genome.fa | tr -d '\n' | wc -c
## 398,942,710 bp ≈ 399 Mb
#log2(398,942,710) ≈ 28.57
#28.57 / 2 − 1 ≈ 13.29
#floor(13.29) = 13
#min(14, 13) = 13

# Try on Stampede3
rsync -av dmflores@ls6.tacc.utexas.edu:$SCRATCH/OfavGenome $SCRATCH
# from ls6 export conda environment
conda env export --from-history > STAR-env.yml   # --from-history avoids LS6-specific build pins

conda env create -f $SCRATCH/STAR-env.yml

idev -p skx-dev -N 1 -n 1 -t 02:00:00 -A IBN21018

# 1. Convert GFF3 -> GTF
gffread Colpophyllia_natans.gff3 -T -o Colpophyllia_natans.gtf

# 2. VERIFY the GTF has gene_id on exon lines (do not skip this)
grep -P "\texon\t" Colpophyllia_natans.gtf | head -2

# 3. Rebuild into a FRESH directory with default tags (no --sjdbGTFtag* flags)
STAR --runMode genomeGenerate \
  --genomeDir cnat_star \
  --genomeFastaFiles Colpophyllia_natans.genome.fa \
  --sjdbGTFfile Colpophyllia_natans.gtf \
  --sjdbOverhang 100 \
  --genomeSAindexNbases 13 \
  --runThreadN 10

# 4. VERIFY before aligning — this is the check that matters
wc -l cnat_star/geneInfo.tab
head cnat_star/geneInfo.tab

# Check STAR built splice junctions: 
wc -l cnat_star/sjdbList.out.tab
head cnat_star/sjdbInfo.tab


# Copy files from LS6
rsync -av dmflores@ls6.tacc.utexas.edu:$SCRATCH/LarvalGE/CNAT $SCRATCH/CNAT

cd $SCRATCH/LarvalGE/CNAT   # or wherever CNAT/ and star_index/ live
mkdir -p aligned logs

# runThreadN 48 for skx-dev
> star.cmds
for F in files/*.trim.fastq; do
  base=$(basename "$F" .trim.fastq)
  echo "STAR --runMode alignReads --genomeDir $SCRATCH/cnat_genome/cnat_star --readFilesIn $F --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20 --runThreadN 28 --outFileNamePrefix aligned/${base}_" >> star.cmds
done
wc -l star.cmds     # should equal your CNAT sample count

# generate slurm script
mkjob.sh -n star -j star.cmds -q pvc -c 28 -e STAR
sbatch star.slurm


###########
# Tried with gff3 but did not work 
conda activate STAR
STAR --runMode genomeGenerate \
  --genomeDir cnat_star \
  --genomeFastaFiles Colpophyllia_natans.genome.fa \
  --sjdbGTFfile Colpophyllia_natans.gff3 \
  --sjdbGTFtagExonParentTranscript Parent \
  --sjdbGTFtagExonParentGene gene_id \
  --sjdbGTFtagExonParentGeneName Name \
  --sjdbOverhang 100 \
  --genomeSAindexNbases 13 \
  --runThreadN 8 
########### for ls6 - old 
## Edit StarAlignment.sh 
conda activate STAR
sbatch CNAT_STAR-Alignment.sh

cd $SCRATCH/LarvalGE/CNAT_STAR_Output
echo "conda run -n qc multiqc *Log.final.out" > STARmultiqc

ls6_launcher_creator.py -q vm-small -j STARmultiqc -n STARmultiqc -t 2:00:00 -a IBN21018 -e dmflores@utexas.edu

conda activate qc 
sbatch STARmultiqc.slurm

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/2CHInS/STAR_Output/multiqc_report.html .

