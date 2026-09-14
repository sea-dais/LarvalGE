# 1. Check all files have the same number of gene rows
for f in aligned/*_ReadsPerGene.out.tab; do
  echo -e "$(tail -n +5 "$f" | wc -l)\t$f"
done

# use build_matrix_py
conda activate ngs-tools
build_matrix.py ./aligned

scp dmflores@stampede3.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/OFAV/ofav_counts.tsv .


# also build matrix for 2021 ofav samples 
conda activate ngs-tools
build_matrix.py ./aligned2021 -o ofav21_counts.tsv

scp dmflores@stampede3.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/OFAV/ofav21_counts.tsv .
