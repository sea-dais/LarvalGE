#---------------------------------------
# generating read-counts-per gene 
# Set the paths to the input and output files
inputFilePath="Pstr_seq2iso.tab"
outputFilePath="Pstr_seq.tab"

# Duplicate the first column and save it to the output file
awk '{print $1 " " $1}' "$inputFilePath" > "$outputFilePath"


conda activate genomeenv
# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' '/work/08717/dmflores/ls6/Pstr/Pstr_seq.tab' > sc
# execute all commands in 'sc' file

ls6_launcher_creator.py -j sc -n sc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 
nano sc.slurm

sbatch sc.slurm

# assembling all counts into a single table:
expression_compiler.pl *.sam.counts > allcounts.txt


#On Local Computer
cd /Users/daisyflores/Desktop/DLAB
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB/\*txt .



samtools view W4-3_S168_L002_R1_001.trim.sam

