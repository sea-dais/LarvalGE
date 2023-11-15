#---------------------------------------
# generating read-counts-per gene 
awk '$1 ~ /^#/ {next} {for (i=1; i<=NF; i++) if ($i ~ /^GO:/) {print $1 "\t" $i; break}}' Pstr_cdna.out.emapper.annotations > Pstr_seq2iso.tab
#/work/08717/dmflores/ls6/Pstr/Pstr_seq2iso.tab

# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' /work/08717/dmflores/ls6/Pstr/Pstr_seq2iso.tab > sc
# execute all commands in 'sc' file
conda activate genomeenv 
# check if samtools installed in environment 
conda list 

ls6_launcher_creator.py -j sc -n sc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 
nano sc.slurm

sbatch sc.slurm

# assembling all counts into a single table:
expression_compiler.pl *.sam.counts > allcounts.txt


#On Local Computer
cd /Users/daisyflores/Desktop/DLAB
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB/\*txt .