#--- Install Tag Seq Scripts
git clone https://github.com/z0on/tag-based_RNAseq.git

#add path to the directory tag-based_RNAseq to your $PATH
/home1/08717/dmflores/bin/tag-based_RNAseq

##START
cd /scratch/08717/dmflores/LarvalGE/FastqFiles
gunzip *.gz

##-------------TRIM
# (Assuming we have many files with extension fastq, and we have cutadapt installed and working)
# adaptor trimming, deduplicating, and quality filtering.
# Work from $SCRATCH.

# STEP 1: Build the commands file — ONE line per sample.
>clean
for F in files/*.fastq.gz; do
  base_name=$(basename $F _L002_R1_001.fastq.gz);
  echo "tagseq_clipper.pl $F | cutadapt - -a AAAAAAAA -a AGATCGG -q 15 -m 25 -o ${base_name}.trim.fastq" >>clean;
done
wc -l clean                 # sanity check: should equal your sample count

# STEP 2: Generate the Slurm script.
#   -c 1 : the pipe is single-threaded (no -j flag on cutadapt).
#   -t 02:00:00 to match the old 2-hour request.
#   -e cutadapt : conda env named 'cutadapt' (from your `conda activate cutadapt`).
mkjob.sh -n clean -j clean -q rtx-small -c 1 -t 02:00:00 -e cutadapt

# STEP 3: Submit.
sbatch clean.slurm

## no goods? # skip tagseq clipper
cd /scratch/08717/dmflores/LarvalGE
conda activate cutadapt

> clean
for F in files/*.fastq.gz; do
  base_name=$(basename "$F" _L002_R1_001.fastq.gz)
  echo "cutadapt -a 'A{20}' -a AGATCGGAAGAGC -g AGATCGGAAGAGC -q 15 -m 25 --max-n 0.1 -o ./TrimmedFQ/${base_name}.trim.fastq $F" >> clean
done

wc -l clean
mkjob.sh -n clean -j clean -q rtx-small -c 1 -t 02:00:00 -e cutadapt
sbatch clean.slurm

# qc the trimmed files: 
mkdir -p TrimmedQC
>fastqc
for file in TrimmedFQ/*.trim*; do
  echo "fastqc ${file} -o ./TrimmedQC" >>fastqc;
done
wc -l fastqc                # sanity check: should equal your file count

# Generate the Slurm script.
#   -c 1 : one fastqc call per task is single-threaded here.
mkjob.sh -n fastqc -j fastqc -c 1 -q skx-dev -t 02:00:00 -e qc

sbatch fastqc.slurm


##-------------TRIM for ls6 
# (Assuming we have many files with extension fastq, and we have cutadapt installed and working)
# adaptor trimming, deduplicating, and quality filtering:
conda activate cutadapt
# creating cleaning process commands for all files:
>clean
for F in FastqFiles/*.fastq.gz; do
base_name=$(basename $F _L002_R1_001.fastq.gz);
echo "tagseq_clipper.pl $F | cutadapt - -a AAAAAAAA -a AGATCGG -q 15 -m 25 -o ${base_name}.trim.fastq" >>clean;
done

# now execute all commands written to file 'clean', preferably in parallel (see Note in the beginning of this walkthrough)
ls6_launcher_creator.py -j clean -n clean -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano clean.slurm
sbatch clean.slurm

## no goods? # skip tagseq clipper
cd /scratch/08717/dmflores/LarvalGE
conda activate cutadapt

> clean
for F in FastqFiles/*_L002_R1_001.fastq.gz; do
  base_name=$(basename "$F" _L002_R1_001.fastq.gz)
  echo "cutadapt -a 'A{20}' -a AGATCGGAAGAGC -g AGATCGGAAGAGC -q 15 -m 25 --max-n 0.1 -o ./TrimmedFQ/${base_name}.trim.fastq $F" >> clean
done

#move files to TrimmedFQ
cd ..
mkdir TrimmedFQ

cd Fastq
mv ./FastqFiles/*trim.fastq ./TrimmedFQ

cd ./TrimmedFQ

##-------------FASTQC
cd /scratch/08717/dmflores/LarvalGE/
mkdir QChtml

cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ
conda activate qc

>fastqc
for file in TrimmedFQ/*.trim*; do
base_name=$(basename $file .trim);
echo "fastqc ${file} –o ./FastQC/${base_name}.trimmed.qc.html" >>fastqc;
done

ls6_launcher_creator.py -j fastqc -n fastqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
sbatch fastqc.slurm

mv *fastqc* ../FastQC/

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/FastQC/\*trim_fastqc.html .