#--- Install Tag Seq Scripts
git clone https://github.com/z0on/tag-based_RNAseq.git

#add path to the directory tag-based_RNAseq to your $PATH
/home1/08717/dmflores/bin/tag-based_RNAseq

##START
cd /scratch/08717/dmflores/LarvalGE/FastqFiles
gunzip *.gz
##-------------TRIM
# (Assuming we have many files with extension fastq, and we have cutadapt installed and working)
# adaptor trimming, deduplicating, and quality filtering:
conda activate cutadaptenv
# creating cleaning process commands for all files:
>clean
for F in *.fastq; do
base_name=$(basename $F _L002_R1_001.fastq);
echo "tagseq_clipper.pl $F | cutadapt - -a AAAAAAAA -a AGATCGG -q 15 -m 25 -o ${base_name}.trim.fastq" >>clean;
done

# now execute all commands written to file 'clean', preferably in parallel (see Note in the beginning of this walkthrough)
ls6_launcher_creator.py -j clean -n clean -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano clean.slurm
sbatch clean.slurm

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
for file in *.trim*; do
base_name=$(basename $file .trim);
echo "fastqc ${file} –o ${base_name}.qc.html" >>fastqc;
done

ls6_launcher_creator.py -j fastqc -n fastqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano fastqc.slurm
sbatch fastqc.slurm

mv *fastqc* ../QChtml/