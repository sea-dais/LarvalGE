idev -t 2:00:00 
conda create -n ips-java -c conda-forge openjdk=11 -y
conda activate ips-java

mkdir -p $SCRATCH/interproscan && cd $SCRATCH/interproscan
wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.78-109.0/interproscan-5.78-109.0-64-bit.tar.gz
wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.78-109.0/interproscan-5.78-109.0-64-bit.tar.gz.md5
md5sum -c interproscan-5.78-109.0-64-bit.tar.gz.md5    # must say: OK

tar -pxzf interproscan-5.78-109.0-64-bit.tar.gz
cd interproscan-5.78-109.0
python3 setup.py -f interproscan.properties
echo $?          # should print 0

# Run 
cd $SCRATCH/interproscan
mkdir -p logs
IPS=$SCRATCH/interproscan/interproscan-5.78-109.0/interproscan.sh

> ips_4sp.cmds
for sp in ofav amil cnat dlab; do
  mkdir -p tmp_${sp}
  echo "$IPS -i $SCRATCH/proteomes/${sp}_clean.faa -b $SCRATCH/interproscan/${sp}_ips -f TSV,GFF3 -goterms -pa -iprlookup --disable-precalc -cpu 28 -T $SCRATCH/interproscan/tmp_${sp}" >> ips_4sp.cmds
done
wc -l ips_4sp.cmds         # should be 4

mkjob.sh -n ips_4sp -j ips_4sp.cmds -c 28 -q spr -t 48:00:00 -e ips-java
sbatch ips_4sp.slurm


# Check: 
for sp in amil cnat dlab; do
  cut -f1-14 ${sp}_ips.tsv > ${sp}_ips_trim.tsv
  echo "$sp: $(cut -f1 ${sp}_ips_trim.tsv | sort -u | wc -l) proteins with a signature"
done