#Working Directory 
/scratch/08717/dmflores/Amillepora/fastqfiles

# Quality Check with FastQC 
mkdir FastQC

>fastqc
for file in *fastq; do
base_name=$(basename $file .fastq);
echo "fastqc ${file} –o FastQC/${base_name}.html" >>fastqc;
done

ls6_launcher_creator.py -j fastqc -n fastqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 
nano fastqc.slurm

sbatch fastqc.slurm
squeue -u dmflores