#!/bin/bash
#SBATCH --job-name=star_alignment
#SBATCH --nodes=2
#SBATCH --ntasks=21
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=star_alignment_%j.log
#SBATCH -A IBN21018
#SBATCH -p development

# Define variables
GENOME_DIR="$WORK/db/amil/star_index"
FASTQ_DIR="$SCRATCH/Amillepora/TrimmedFQ"
OUTPUT_DIR="$SCRATCH/Amillepora/Amil_STAR_Output"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Get our data files
FILES=${FASTQ_DIR}/*.fastq

for f in $FILES
do
    echo "Processing file: $f"
    filename=$(basename $f)
    base=${filename%%_*}
    echo "Base name: $base"
    
    STAR --runThreadN $SLURM_CPUS_PER_TASK \
         --genomeDir $GENOME_DIR \
         --sjdbGTFfile $GENOME_DIR/amil.gtf \
         --readFilesIn $f \
         --outSAMtype BAM SortedByCoordinate \
         --quantMode GeneCounts \
         --outFileNamePrefix ${OUTPUT_DIR}/${base}_ \
         --outSAMattributes NH HI AS nM NM MD

    # Index BAM file
    samtools index ${OUTPUT_DIR}/${base}_Aligned.sortedByCoord.out.bam
done

echo "Job completed successfully!"