cd $WORK/orthofinder/proteins 

grep -c ">" *.fa
# Amil.fa:28189
# Cnat.fa:29090
# Dlab.fa:24564
# Hvul.fa:21385
# Nvec.fa:20535
# Ocupat.fa:39482
# Ofav.fa:25929
# Spis.fa:29419

cd $SCRATCH/orthofinder   # or wherever you keep this job's .cmds/.slurm files
mkdir -p logs

# STEP 1: commands file (single line; OrthoFinder is one big multithreaded job)
dir=$WORK/orthofinder/proteins
echo "orthofinder -f $dir -t 112 -a 28 -o $SCRATCH/orthofinder/out_8sp" > OF8sp.cmds
wc -l OF8sp.cmds   # should be 1

# STEP 2: Slurm script. -c 112 gives this one task the whole spr node
mkjob.sh -n OF8sp -j OF8sp.cmds -c 112 -t 18:00:00 -e orthofinder_env

# STEP 3: submit
sbatch OF8sp.slurm

ls -lh Orthogroups/Orthogroups.tsv
ls -lh Species_Tree/SpeciesTree_rooted.txt
ls -lh Comparative_Genomics_Statistics/Statistics_Overall.tsv
ls -lh Orthologues/

## ran out of memory at STRIDE Step,
sacct -j 3531660 --format=JobID,MaxRSS,ReqMem,State
## check working directory for progress: 

cd $SCRATCH/orthofinder/out_8sp/Results_Sep23/WorkingDirectory

echo "orthofinder -ft $SCRATCH/orthofinder/out_8sp/Results_Sep23/ -t 64 -a 8" > finishOrthofinder.cmds
wc -l finishOrthofinder.cmds  

mkjob.sh -n orthofinder_ft -j finishOrthofinder.cmds -c 80 -q icx -t 12:00:00 -e orthofinder_env
sbatch orthofinder_ft.slurm

## could not find rooted species tree: 
# create manually: 

conda activate orthofinder_env
conda install conda-forge::ete3

python -c "
from ete3 import Tree
t = Tree('SpeciesTree_unrooted.txt', format=1)
t.set_outgroup('Hvul')
print(t.get_ascii(show_internal=False))
t.write(outfile='SpeciesTree_rooted_manual.txt', format=1)
"

# Try running job again: 
echo "orthofinder -ft $SCRATCH/orthofinder/out_8sp/Results_Sep23 \
  -s $SCRATCH/orthofinder/out_8sp/Results_Sep23/WorkingDirectory/SpeciesTree_rooted_manual.txt \
  -t 64 -a 8" > finishOrthofinder2.cmds
wc -l finishOrthofinder2.cmds  

mkjob.sh -n orthofinder_ft2 -j finishOrthofinder2.cmds -c 80 -q icx -t 12:00:00 -e orthofinder_env
sbatch orthofinder_ft2.slurm

squeue --me --start


cd Orthogroups
awk -F'\t' '
{sub(/\r$/,"")}
FNR==1 {for(i=2;i<=NF;i++) h[i]=$i; next}
FILENAME==ARGV[1] {for(i=2;i<=NF;i++) if(h[i]!="Total") a[h[i]]+=$i}
FILENAME==ARGV[2] {for(i=2;i<=NF;i++) if($i!="") u[h[i]]++}
END {
  printf "%-10s %10s %10s %10s\n","Species","Assigned","Unassigned","%Assigned"
  for(s in a){t=a[s]+u[s]; printf "%-10s %10d %10d %9.1f%%\n",s,a[s],u[s],100*a[s]/t; A+=a[s]; U+=u[s]}
  printf "%-10s %10d %10d %9.1f%%\n","ALL",A,U,100*A/(A+U)
}' Orthogroups.GeneCount.tsv Orthogroups_UnassignedGenes.tsv

# Combine directories
OUT=/scratch/08717/dmflores/orthofinder/out_8sp
OLD=$OUT/Results_Sep23
NEW=$OUT/Results_Sep25_1        # <-- the -ft run's folder
COMB=$OUT/Results_combined

mkdir -p "$COMB"

# 1. Copy the full Sep23 run
rsync -a "$OLD"/ "$COMB"/
mv "$COMB/Log.txt" "$COMB/Log_Sep23_initial.txt"

# 2. Copy in the -ft run, replacing same-named folders entirely
for item in "$NEW"/*; do
  name=$(basename "$item")
  if [ "$name" = "WorkingDirectory" ]; then
    cp -a "$item" "$COMB/WorkingDirectory_ft"     # keep both working dirs
  else
    rm -rf "$COMB/$name"
    cp -a "$item" "$COMB/"
  fi
done

ls "$COMB"

rsync -a "$COMB" $WORK/orthofinder_8sp/