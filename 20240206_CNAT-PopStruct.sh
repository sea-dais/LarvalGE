#--------------- population structure, HWE (common variants, maf>0.05)

# Note: PCA and Admixture are not supposed to be run on data that contain clones (or genotyping replicates); remove them from bams list. If you want to detect clones, however, do keep the replicates and analyse identity-by-state (IBS) matrix (explained below)

# Generating genotype likelihoods from highly confident (non-sequencing-error) SNPs

# F I L T E R S :
# (ALWAYS record your filter settings and explore different combinations to confirm that results are robust. )
# Suggested filters :
# -minMapQ 20 : only highly unique mappings
# -minQ 30 : only highly confident base calls
# -minInd : the site must be genotyped in at least that many individuals (setting this to 80% of  total number of  individuals here)
# -snp_pval 1e-5 : high confidence that the SNP is not just sequencing error 
# -minMaf 0.05 : only common SNPs, with allele frequency 0.05 or more. Consider raising this to 0.1 for population structure analysis.
# Note: the last two filters are very efficient against sequencing errors but introduce bias against true rare alleles. It is OK (and even desirable) - UNLESS we want to do AFS analysis. We will generate data for AFS analysis in the next part.
# also adding filters against very badly non-HWE sites (such as, all calls are heterozygotes => lumped paralog situation):

conda create -n ANGSD
conda install bioconda::angsd

cd /scratch/08717/dmflores/LarvalGE/TrimmedFQ/CNAT
ls -l *fastq | wc
#50

###----------Ref Transcriptome
# mapping reads to transcriptome
export REF="/scratch/08717/dmflores/KBeavers/Transcriptomes/Cnat_reference_transcriptome.fa"
# creating bowtie2 index for your transcriptome:
bowtie2-build Cnat_reference_transcriptome.fa Cnat_reference_transcriptome.fa 

# cd where the trimmed read files are (extension "trim")
tagseq_bowtie2map.pl "trim.fastq$" $REF  > maps
# execute all the commands in 'maps', record screen output in some file

ls6_launcher_creator.py -j maps -n maps -t 02:00:00 -a IBN21018 -e dmflores@utexas.edu
sbatch maps.slurm

# alignment rates:
grep "overall alignment rate"  maps.e1502546 > alignmentrate.txt

#Convert sam to bam and index
>s2b
for file in *.sam; do
echo "samtools view -Sb -o ${file/.sam/}.bam $file && samtools index ${file/.sam/}.bam">>s2b;
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

FILTERS="-uniqueOnly 1 -remove_bads 1 -minMapQ 20 -minQ 20 -baq 1 -minInd $MI -snp_pval 1e-5 -minMaf 0.05 -dosnpstat 1 -doHWE 1 -hetbias_pval 1e-5 -skipTriallelic 1"

# THINGS FOR ANGSD TO DO : 
# -GL 1 : samtools likelihood model
# -doGlf 2 : output genotype likelihoods in beagle format (for admixture)
# -doPost 1 : output posterior allele frequencies based on HWE prior
# -doMajorMinor 1 : infer major and minor alleles from data (not from reference)
# -makeMatrix 1 -doIBS 1 : identity-by-state and covariance matrices based on single-read resampling (robust to variation in coverage across samples)
TODO="-doMajorMinor 1 -doMaf 1 -doCounts 1 -makeMatrix 1 -doIBS 1 -doGeno 32 -doVcf 1 -doPost 1 -doGlf 2"

# Starting angsd with -P the number of parallel processes. Funny but in many cases angsd runs faster on -P 1
angsd -b bams -GL 1 $FILTERS $TODO -P 1 -out myresult

# how many SNPs?
NSITES=`zcat myresult.beagle.gz | wc -l`
echo $NSITES

# use myresult.covMat and myresult.ibsMat from angsd run for PCoA and PCA (see last line of this section).

# NgsAdmix for K from 2 to 5
for K in `seq 2 5` ; 
do 
NGSadmix -likes myresult.beagle.gz -K $K -P 10 -o mydata_k${K};
done

# scp the *.Q and inds2pops files to laptop, plot it in R:
# use admixturePlotting2a.R to plot (will require minor editing - population names)

# scp *Mat, *covar, *qopt and bams files to laptop, use angsd_ibs_pca.R to plot PCA and admixturePlotting_v4.R to plot ADMIXTURE

#==========================
# ANDSD => SFS and heterozygosity 

PercInd=0.75
NIND=`cat bams | wc -l`
MI=`echo "($NIND*$PercInd+0.5)/1" | bc`

# now not filtering for allele frequency
# sb - strand bias filter; only use for 2bRAD, GBS or WGS (not for ddRAD or RADseq)
# hetbias - detects weird heterozygotes because they have unequal representation of alleles 
# setting minInd to 50% of all  individuals (might depend on the results from quality control step)
MI=`cat bams | wc -l | awk '{print int($1*0.5)}'`
GENOME_REF=all_cc.fasta
FILTERS="-uniqueOnly 1 -remove_bads 1  -skipTriallelic 1 -minMapQ 30 -minQ 25 -hetbias_pval 1e-5 -minInd $MI"
TODO="-doHWE 1 -doMajorMinor 1 -doMaf 1 -dosnpstat 1 -doGeno 32 -doSaf 1 -anc $GENOME_REF -fold 1"
angsd -b bams -GL 1 -P 12 $FILTERS $TODO -out div

# generating SFS
realSFS div.saf.idx -P 6 > div.sfs


#-------------- estimate theta 

GENOME_REF=all_cc.fasta
FILTERS="-uniqueOnly 1 -remove_bads 1  -skipTriallelic 1 -minMapQ 30 -minQ 25 -hetbias_pval 1e-5 -minInd $MI"
angsd -bam bams -out div2 -doThetas 1 -doSaf 1 -pest div.sfs -anc $GENOME_REF -GL 1

# log-scale per-site thetas:
thetaStat print div2.thetas.idx 2>/dev/null > logThetas