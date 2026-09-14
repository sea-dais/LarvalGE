# 1. Check all files have the same number of gene rows
for f in aligned/*_ReadsPerGene.out.tab; do
  echo -e "$(tail -n +5 "$f" | wc -l)\t$f"
done

# use build_matrix_py
conda activate ngs-tools
build_matrix.py ./aligned

scp dmflores@stampede3.tacc.utexas.edu:/scratch/08717/dmflores/LarvalGE/DLAB/dlab_counts.tsv .