# List and count BAM files
ls $SCRATCH/LarvalGE/CNAT_STAR_Output/*.bam | wc -l

# Create a list of BAM files
ls $SCRATCH/LarvalGE/CNAT_STAR_Output/*.bam > bams

# remove from bams file
K2.1	#CN3-S7	
N4.5    #CN5-S14	
W2.1    #CN7-S19	
W2.3    #CN9-S25	
W2.4    #CN11-S31	
N4.2    #CN17-S51	
N4.3    #CN18-S54	
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

conda activate ANGSD
# Starting angsd with -P the number of parallel processes. Funny but in many cases angsd runs faster on -P 1
echo "angsd -b bams -GL 1 $FILTERS $TODO -P 1 -out myresult" > runangsd

ls6_launcher_creator.py -j runangsd -n runangsd -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
nano runangsd.slurm
sbatch runangsd.slurm
# how many SNPs?
NSITES=`zcat myresult.beagle.gz | wc -l`
echo $NSITES

# use myresult.covMat and myresult.ibsMat from angsd run for PCoA and PCA 

# scp *Mat, *covar, *qopt and bams files to laptop, use angsd_ibs_pca.R to plot PCA and admixturePlotting_v4.R to plot ADMIXTURE
myresult.covMat
myresult.ibs.gz 
myresult.ibsMat  

scp $LS6:$SCRATCH/LarvalGE/myresult.ibsMat ./cnat_ibsMat-filt
scp $LS6:$SCRATCH/LarvalGE/bams ./cnat_bams-filt


