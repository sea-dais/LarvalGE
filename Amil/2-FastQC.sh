#Working Directory 
/scratch/08717/dmflores/LarvalGE/AMIL

# Quality Check with FastQC 
mkdir FastQC 

########### for stampede3
conda activate qc
> fastqc.cmds
for file in Amil_FastqFiles/*fastq; do
  echo "fastqc ${file} -o FastQC/" >> fastqc.cmds
done
wc -l fastqc.cmds          # sanity check: should equal your file count

#   fastqc is single-threaded per file -> -c 1
mkjob.sh -n fastqc -j fastqc.cmds -c 1 -t 02:00:00 -e qc
sbatch fastqc.slurm

# copy files
REMOTE=dmflores@stampede3.tacc.utexas.edu:/scratch/08717/dmflores/

scp "$REMOTE/LarvalGE/AMIL/FastQC" .

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