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
echo "orthofinder -f $dir -t 112 -a 28 -o $WORK/orthofinder/out_8sp" > OF8sp.cmds
wc -l OF8sp.cmds   # should be 1

# STEP 2: Slurm script. -c 112 gives this one task the whole spr node
mkjob.sh -n OF8sp -j OF8sp.cmds -c 112 -t 24:00:00 -e orthofinder_env

# STEP 3: submit
sbatch OF8sp.slurm