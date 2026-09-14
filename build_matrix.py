#!/usr/bin/env python3
import sys, glob, os, argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("directory")
parser.add_argument("-o", "--output", default="counts.tsv", help="output counts file name")
args = parser.parse_args()

directory = args.directory
col = 1  # 0-based column index into the count columns: 1=unstranded(col2), 2=fwd, 3=rev

files = sorted(glob.glob(os.path.join(directory, "*ReadsPerGene.out.tab")))
if not files:
    sys.exit(f"No ReadsPerGene.out.tab files in {directory}")

series = {}
for f in files:
    sample = os.path.basename(f).replace("_ReadsPerGene.out.tab", "")
    df = pd.read_csv(f, sep="\t", skiprows=4, header=None,
                     usecols=[0, col+1], index_col=0)
    series[sample] = df.iloc[:, 0]

matrix = pd.DataFrame(series)          # aligns on gene ID index automatically
matrix.index.name = "GeneID"
matrix = matrix.sort_index()

# checks
assert matrix.notna().all().all(), "some genes missing from some samples!"
assert not matrix.index.duplicated().any(), "duplicate gene IDs!"

matrix.to_csv(args.output, sep="\t")
print(f"{matrix.shape[0]} genes x {matrix.shape[1]} samples -> {args.output}")