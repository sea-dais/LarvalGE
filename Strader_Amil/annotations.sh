cut -f9 ../amil.gtf | head -3
grep -c "LOC" ../amil.gtf
cut -f9 amil.gtf | head -3
grep -c "LOC" amil.gtf

rsync -avp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/coral_genomes/amil_genome2/Amil_v2.01_annotated .

cd amil_genome
grep -c ">" Amil.all.maker.proteins.fasta
grep ">" Amil.all.maker.proteins.fasta | head -3
# how many repo gene IDs exist in your local annotation?
comm -12 <(grep ">" $WORK/orthofinder/proteins/Amil.fa | sed 's/>Amil_//; s/-R[A-Z]*$//' | sort -u) \
         <(grep ">" Amil.all.maker.proteins.fasta | cut -d' ' -f1 | sed 's/>//; s/-R[A-Z]*$//' | sort -u) | wc -l
grep -c ">" $WORK/orthofinder/proteins/Amil.fa