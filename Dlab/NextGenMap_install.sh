conda create -n nextGenMap
conda install nextgenmap

ngm -q reads.fastq -r reference-sequence.fa -o results.sam -t 4 -g
