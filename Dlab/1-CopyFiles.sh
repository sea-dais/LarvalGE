# also copy over files from 2021
while read -r prefix; do
  [ -z "$prefix" ] && continue          # skip blank lines
  cp TrimmedFQ/"${prefix}"_*.trim.fastq DLAB/ 2>/dev/null
done < DLAB_prefixlist.txt