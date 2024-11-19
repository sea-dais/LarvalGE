#---------------------------------------
# generating read-counts-per gene 
make_clusters2isogroups.pl Amil.all.maker.transcripts.fasta > clusters2isogroups.tab

TAB="/work/08717/dmflores/ls6/db/Amil_v2.01_annotated/Amil_clusters2isogroups.tab"

## 
cd /scratch/08717/dmflores/LarvalGE/AMIL/TrimmedFQ

conda activate genomeenv
# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' $TAB > sc
# execute all commands in 'sc' file

ls6_launcher_creator.py -j sc -n sc -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu 

sbatch sc.slurm

# assembling all counts into a single table:
expression_compiler.pl *.sam.counts > Amil_allcounts.txt


#On Local Computer
cd /Users/daisyflores/Desktop/Projects/LarvalGE/AMIL/data
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/AMIL/TrimmedFQ/\*txt .

