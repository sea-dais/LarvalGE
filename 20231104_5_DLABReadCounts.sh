#---------------------------------------
# generating read-counts-per gene 
/work/08717/dmflores/ls6/Pstr
cd-hit-est -i Pseudodiploria_strigosa_cds_100.final.clstr.fna -o transcriptome_clust.fasta -c 0.99 -G 0 -aL 0.3 -aS 0.3
isogroup_namer.pl transcriptome_clust.fasta transcriptome_clust.fasta.clstr >transcriptome_seq2gene.tab

/work/08717/dmflores/ls6/Pstr/Pseudodiploria_strigosa_cds_100_iso_seq2iso.tab

conda activate bowtie2
# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' '/work/08717/dmflores/ls6/Pstr/Pseudodiploria_strigosa_cds_100_iso_seq2iso.tab' > sc
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

