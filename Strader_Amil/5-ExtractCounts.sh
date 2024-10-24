## Use ExtractCounts.sh
## Make Executable 

chmod +x ExtractCounts_nu.sh

export OUT_DIR="$SCRATCH/LarvalGE/AMIL/STAR_Output"

ExtractCounts_nu.sh $OUT_DIR


## On local Computer
cd /Users/daisyflores/Desktop/Projects/LarvalGE/AMIL/data/

LS6="dmflores@ls6.tacc.utexas.edu"
SCRATCH="/scratch/08717/dmflores"
HOME="/home1/08717/dmflores"
WORK="/work/08717/dmflores/ls6"

scp $LS6:$SCRATCH/LarvalGE/AMIL/counts.txt ./Amil_counts.txt