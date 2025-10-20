#Working Directory 
/scratch/08717/dmflores/LarvalGE

# Quality Check with FastQC 
mkdir FastQC

>fastqc
for file in *fastq.gz; do
base_name=$(basename $file .fastq.gz);
echo "fastqc ${file} –o FastQC/${base_name}.html" >>fastqc;
done

ls6_launcher_creator.py -j fastqc -n fastqc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 
nano fastqc.slurm

sbatch fastqc.slurm
squeue -u dmflores

#--- Install Tag Seq Scripts
git clone https://github.com/z0on/tag-based_RNAseq.git

#add path to the directory tag-based_RNAseq to your $PATH
/home1/08717/dmflores/bin/tag-based_RNAseq

#--- 