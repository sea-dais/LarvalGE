## Use ExtractCounts.sh
## Make Executable 

chmod +x ExtractCounts.sh

export OUT_DIR="$SCRATCH/LarvalGE/CNAT_STAR_Output/"

./ExtractCounts.sh $OUT_DIR


## On local Computer
cd /Users/daisyflores/Desktop/Projects/LarvalGE/CNAT/WithNewGenome

LS6="dmflores@ls6.tacc.utexas.edu"
SCRATCH="/scratch/08717/dmflores"
HOME="/home1/08717/dmflores"
WORK="/work/08717/dmflores/ls6"

scp $LS6:$SCRATCH/LarvalGE/CNAT_counts.txt .