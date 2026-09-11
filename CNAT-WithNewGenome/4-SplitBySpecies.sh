#Use Split by Species.sh

#Create prefix list of all the files 
ls | cut -d'_' -f1 | sort -u > file_list.txt

nano CNAT_prefixlist.txt

mkdir -p CNAT

while read -r prefix; do
  [ -z "$prefix" ] && continue          # skip blank lines
  cp TrimmedFQ/"${prefix}"_*.trim.fastq CNAT/ 2>/dev/null
done < CNAT_prefixlist.txt

while read -r prefix; do
  [ -z "$prefix" ] && continue
  ls TrimmedFQ/"${prefix}"_*.trim.fastq >/dev/null 2>&1 || echo "NO MATCH: $prefix"
done < CNAT_prefixlist.txt
# NO MATCH: G3-3