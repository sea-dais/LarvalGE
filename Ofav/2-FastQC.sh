#Working Directory 
/scratch/08717/dmflores/LarvalGE

# Quality Check with FastQC 
mkdir FastQC-26 # only for 2025/26 files 

########### for stampede3
> fastqc.cmds
for file in files/*fastq.gz; do
  echo "fastqc ${file} -o FastQC-26/" >> fastqc.cmds
done
wc -l fastqc.cmds          # sanity check: should equal your file count
mkdir -p FastQC-26         # output dir fastqc writes to

#   fastqc is single-threaded per file -> -c 1
mkjob.sh -n fastqc -j fastqc.cmds -c 1 -t 02:00:00 -e qc
sbatch fastqc.slurm

########### for ls6 
>fastqc
for file in files/*fastq.gz; do
base_name=$(basename $file L002_R1_001.fastq.gz);
echo "fastqc ${file} –o FastQC-26/${base_name}.html" >>fastqc;
done

ls6_launcher_creator.py -j fastqc -n fastqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 
nano fastqc.slurm

sbatch fastqc.slurm
squeue -u dmflores


###### on idev 
mkdir -p FastQC
for file in FastqFiles/*fastq.gz; do
  fastqc "$file" -o FastQC/
done