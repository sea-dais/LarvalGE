ssh dmflores@ls6.tacc.utexas.edu

cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB2
ls -l *fastq | wc

###----------Ref Transcriptome
conda activate genomeenv
# mapping reads to transcriptome
# creating bowtie2 index for your transcriptome:
samtools faidx Pstr_reference_transcriptome.fa

bowtie2-build Pstr_reference_transcriptome.fa Pstr_reference_transcriptome.fa

export REF="/scratch/08717/dmflores/KBeavers/Transcriptomes/Pstr_reference_transcriptome.fa"

conda activate ANGSD
cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/DLAB2
>maps
for F in `ls *.fastq`; do
echo "bowtie2 --no-unal -x $REF -U $F -S ${F/.fastq/}.sam">>maps
done
# execute all commands in maps

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate"  maps.e1799183   > alignmentrate.txt

#Convert sam to bam and index
>s2b
for file in *.sam; do
echo "samtools sort -O bam -o ${file/.sam/}.bam $file && samtools index ${file/.sam/}.bam">>s2b;
done


ls6_launcher_creator.py -j s2b -n s2b -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
sbatch s2b.slurm

# execute all commands listed in s2b file
ls *bam | wc -l  # should be the same number as number of sam files

ls *bam > bams


nano bams 
#Remove
#A2.3 A2.4
#B4.1 B4.3 B4.4
#H2.2 H4.3 H2.3 H2.7
#K4.3 K4.4 K4.5
#N2.2
#P4.1 P4.2 P4.3 P4.4
#R4.1 R4.2 R4.3
#T2.1 T2.2 T2.3 T2.4 T2.5 T2.6 T2.7 T2.8
#W4.2 W4.4

###-------------------
PercInd=0.75

NIND=`cat bams | wc -l`
MI=`echo "($NIND*$PercInd+0.5)/1" | bc`

# THINGS FOR ANGSD TO DO : 
# -GL 1 : samtools likelihood model
# -doGlf 2 : output genotype likelihoods in beagle format (for admixture)
# -doPost 1 : output posterior allele frequencies based on HWE prior
# -doMajorMinor 1 : infer major and minor alleles from data (not from reference)
# -makeMatrix 1 -doIBS 1 : identity-by-state and covariance matrices based on single-read resampling (robust to variation in coverage across samples)
FILTERS="-uniqueOnly 1 -remove_bads 1 -minMapQ 20 -minQ 25 -dosnpstat 1 -doHWE 1 -sb_pval 1e-5 -hetbias_pval 1e-5 -skipTriallelic 1 -minInd $MI -snp_pval 1e-5 -minMaf 0.05"
TODO="-doMajorMinor 1 -doMaf 1 -doCounts 1 -makeMatrix 1 -doIBS 1 -doCov 1 -doGeno 8 -dobcf 1 -doPost 1 -doGlf 2"

# Starting angsd with -P the number of parallel processes. Funny but in many cases angsd runs faster on -P 1
conda activate ANGSD
angsd -b bams -GL 1 $FILTERS $TODO -P 1 -out myresult

# how many SNPs?
NSITES=`zcat myresult.beagle.gz | wc -l`
echo $NSITES

# use myresult.covMat and myresult.ibsMat from angsd run for PCoA and PCA 

# scp *Mat, *covar, *qopt and bams files to laptop, use angsd_ibs_pca.R to plot PCA and admixturePlotting_v4.R to plot ADMIXTURE

#myresult.covMat
#myresult.ibs.gz 
#myresult.ibsMat  

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/myresult.ibsMat .

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/bams .