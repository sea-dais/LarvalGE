
## DLAB Files
#20230926_1_CopyFiles from BaseSpace
#20231104_2_Trim.sh

# Replace 'INPUT_DIR' with the directory containing your FASTQ files.
IN_DIR='/scratch/08717/dmflores/LarvalGE/TrimmedFQ'

# Replace 'output_directory' with the directory where you want to copy the selected files.
OUT_DIR='/scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB'

python splitbyspecies.py DLAB_prefixlist.txt -i $IN_DIR -o $OUT_DIR

cd $OUT_DIR

##---Multiqc Trimmed Reads
cd $SCRATCH/LarvalGE/TrimmedFQ/DLAB
echo "conda run -n qc multiqc *fastq" > multiqc

ls6_launcher_creator.py -q development -j multiqc -n multiqc -t 2:00:00 -a IBN21018 -e dmflores@utexas.edu

sbatch multiqc.slurm

## Copy html to local cpu to view
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/AMIL/STAR_Output/multiqc_report.html ./multiqcReport4.html

