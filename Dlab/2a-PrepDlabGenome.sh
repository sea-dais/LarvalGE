pip install zenodo_get

# Downloads https://zenodo.org/records/19135866
zenodo_get 10.5281/zenodo.19135866 -g "*coral-genomes-annotation*"

ls -lh coral-genomes-annotation-v1.0.0.zip   # confirm ~2.1G
unzip -t coral-genomes-annotation-v1.0.0.zip # integrity test — should say "No errors detected"

# Unzip only DLAB
unzip coral-genomes-annotation-v1.0.0.zip "sebametz-coral-genomes-annotation-5d18908/results/jaDipLaby1_Diploria_labyrinthiformis/*"

mv jaDipLaby1_Diploria_labyrinthiformis dlab_genome
# Readme says braker.gtf.gz is the one to use 

