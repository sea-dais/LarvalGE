# 1. Check all files have the same number of gene rows
for f in *_ReadsPerGene.out.tab; do
  echo -e "$(tail -n +5 "$f" | wc -l)\t$f"
done

# 2. Confirm the gene-ID column is byte-for-byte identical across all files
# Compare each file's gene column against the first file's
first=$(ls *_ReadsPerGene.out.tab | head -1)
tail -n +5 "$first" | cut -f1 > .ref_genes

for f in *_ReadsPerGene.out.tab; do
  if tail -n +5 "$f" | cut -f1 | cmp -s - .ref_genes; then
    echo "OK    $f"
  else
    echo "DIFF  $f"
  fi
done

# use build_matrix_py
build_matrix.py ./aligned
