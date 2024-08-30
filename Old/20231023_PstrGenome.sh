#Download P.strigosa genome from http://comparative.reefgenomics.org/datasets.html

scp Pseudo* dmflores@ls6.tacc.utexas.edu:/work/08717/dmflores/ls6/Pstr/

DIR=/work/08717/dmflores/ls6/Pstr
GROUP=G-824270
chgrp $GROUP $DIR
chmod g+x $DIR
chgrp -R $GROUP $DIR
chmod -R g+s $DIR
chmod -R g+rX $DIR
chmod -R 755 $DIR

scp dmflores@ls6.tacc.utexas.edu:/work/08717/dmflores/ls6/Pstr/Pseudodiploria_strigosa_cds_100.final.clstr.fna
