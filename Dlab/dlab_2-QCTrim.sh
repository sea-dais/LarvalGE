cd /scratch/08717/dmflores/LarvalGE/DLAB

# Quality Check with FastQC 
mkdir FastQC

>fastqc_job
for file in ../TrimmedFQ/DLAB/*fastq; do
echo "fastqc ${file} -o ./FastQC" >>fastqc_job;
done

ls6_launcher_creator.py -j fastqc_job -n fastqc_job -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 

conda activate qc
sbatch fastqc_job.slurm
squeue -u dmflores

LS6="dmflores@ls6.tacc.utexas.edu"
SCRATCH="/scratch/08717/dmflores"

cd /Users/daisyflores/Desktop/Projects/LarvalGE/DLAB/TrimmedQC
scp $LS6:$SCRATCH/LarvalGE/DLAB/FastQC/\*html .