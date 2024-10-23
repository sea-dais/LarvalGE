#Working Directory 
cd /scratch/08717/dmflores/LarvalGE/AMIL/

# Quality Check with FastQC 
mkdir FastQC

>fastqc_job
for file in ./Amil_FastqFiles/*fastq; do
base_name=$(basename $file .fastq);
echo "fastqc ${file} –o FastQC/${base_name}.html" >>fastqc_job;
done

ls6_launcher_creator.py -j fastqc_job -n fastqc_job -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 


sbatch fastqc_job.slurm
squeue -u dmflores
