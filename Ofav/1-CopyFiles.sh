#Download Illumina Basespace Command line interface
wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O $HOME/bin/bs

#make it executable
chmod u+x $HOME/bin/bs
#Authenticate
bs auth

bs list projects

# Run command in IDEV or send to computing node
idev -p pvc -N 1 -n 1 -t 02:00:00 -A IBN21018

bs -v download project --name JA26094 --extension=fastq.gz

mkdir -p files
mv */*.fastq.gz files/

ls files/ | wc -l     # should be 21
ls files/

# Remove empty dirs
rmdir */    

##################
# also copy over files from 2021
while read -r prefix; do
  [ -z "$prefix" ] && continue          # skip blank lines
  cp TrimmedFQ/"${prefix}"_*.trim.fastq OFAV/ 2>/dev/null
done < OFAV_prefixlist.txt