conda create -n ANGSD
conda install bioconda::angsd

cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT
ls -l *fastq | wc
#50

###----------Ref Transcriptome
# mapping reads to transcriptome
# creating bowtie2 index for your transcriptome:
samtools faidx Cnat_reference_transcriptome.fa

bowtie2-build Cnat_reference_transcriptome.fa Cnat_reference_transcriptome.fa 

export REF="/scratch/08717/dmflores/KBeavers/Transcriptomes/Cnat_reference_transcriptome.fa"

>maps
for F in `ls *.fastq`; do
echo "bowtie2 --no-unal -x $REF -U $F -S ${F/.fastq/}.sam">>maps
done
# execute all commands in maps

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate"  maps.e1508516 > alignmentrate.txt

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
angsd -b bams -GL 1 $FILTERS $TODO -P 1 -out myresult

# how many SNPs?
NSITES=`zcat myresult.beagle.gz | wc -l`
echo $NSITES

# use myresult.covMat and myresult.ibsMat from angsd run for PCoA and PCA 

# scp *Mat, *covar, *qopt and bams files to laptop, use angsd_ibs_pca.R to plot PCA and admixturePlotting_v4.R to plot ADMIXTURE
myresult.covMat
myresult.ibs.gz 
myresult.ibsMat  

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/myresult.ibsMat .

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/bams .
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT_prefixlist.txt .0C

#### 20240213_Remove outlier fastafiles
#Remove 
#A4.1; CN10-S30
#Q4.1; CN10-S29
#A4.2; CN11-S33
#Q4.2; CN11-S32
#W2.4; CN11-S31
nano bams 
#Delete the bams from this list and write as new file called bams2 
##Has 45 entries

###-------------------
PercInd=0.75
NIND=`cat bams2 | wc -l`
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
angsd -b bams2 -GL 1 $FILTERS $TODO -P 1 -out myresult

# how many SNPs?
NSITES=`zcat myresult.beagle.gz | wc -l`
echo $NSITES

# use myresult.covMat and myresult.ibsMat from angsd run for PCoA and PCA 

# scp *Mat, *covar, *qopt and bams files to laptop, use angsd_ibs_pca.R to plot PCA and admixturePlotting_v4.R to plot ADMIXTURE
myresult.covMat
myresult.ibs.gz 
myresult.ibsMat  

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/myresult.ibsMat ./myresult22.ibsMat

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/bams2 .
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT_prefixlist.txt ./prefixlist.txt

#### 20240214_Remove outlier fastafiles AGAIN
#Remove 
#N4.1: CN12-S34
#Q4.3: CN12-S35
#A4.3: CN12-S35
#W2.3: CN9-S25
nano bams 
#Delete the bams from this list and write as new file called 
#bams3
##Has 41 entries

###-------------------
PercInd=0.75
NIND=`cat bams3 | wc -l`
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
angsd -b bams3 -GL 1 $FILTERS $TODO -P 1 -out myresult3

# how many SNPs?
NSITES=`zcat myresult3.beagle.gz | wc -l`
echo $NSITES

# use myresult.covMat and myresult.ibsMat from angsd run for PCoA and PCA 

# scp *Mat, *covar, *qopt and bams files to laptop, use angsd_ibs_pca.R to plot PCA and admixturePlotting_v4.R to plot ADMIXTURE
myresult.covMat
myresult.ibs.gz 
myresult.ibsMat  

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/myresult3.ibsMat ./myresult3.ibsMat

scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT/bams3 .
scp dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT_prefixlist.txt ./prefixlist.txt