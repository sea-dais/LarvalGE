conda create -n eggnog -c bioconda -c conda-forge eggnog-mapper=2.1.12 -y
conda activate eggnog
mkdir -p $SCRATCH/eggnog_db

# quick check that the new address works (should say "200 OK" and a size)
wget --spider http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.db.gz

wget -c http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.db.gz
wget -c http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog_proteins.dmnd.gz
wget -c http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.taxa.tar.gz

gunzip eggnog.db.gz eggnog_proteins.dmnd.gz
tar -xzf eggnog.taxa.tar.gz && rm eggnog.taxa.tar.gz

ls -lh    # expect eggnog.db (~40 GB), eggnog_proteins.dmnd (~9 GB), eggnog.taxa.db

############
mkdir -p $SCRATCH/eggnog && cd $SCRATCH/eggnog
mkdir -p logs out

> emapper.cmds
for sp in ofav amil cnat dlab; do
  mkdir -p tmp_${sp}
  echo "emapper.py --override --itype proteins -i $SCRATCH/proteomes/${sp}_clean.faa -o ${sp} --output_dir $SCRATCH/eggnog/out --data_dir $SCRATCH/eggnog_db --temp_dir $SCRATCH/eggnog/tmp_${sp} --cpu 12" >> emapper.cmds
done
wc -l emapper.cmds         # should be 4

mkjob.sh -n emapper -j emapper.cmds -c 28 -q spr -t 08:00:00 -e eggnog
sbatch emapper.slurm