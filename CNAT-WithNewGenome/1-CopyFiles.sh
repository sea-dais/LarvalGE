#Download Illumina Basespace Command line interface
wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O $HOME/bin/bs

#make it executable
chmod u+x $HOME/bin/bs
#Authenticate
bs auth

bs list projects

# Run command in IDEV or send to computing node
bs -v download project --name JA23331 --extension=fastq.gz

find LarvalGE -type f -name "*.fastq.gz" -exec mv {} LarvalGE \; -exec rmdir {} \;

#This command does the following:
#find LarvalGE searches for files and directories within the "LarvalGE" directory.
#-type f specifies that we are looking for files, not directories.
#-name "*.fastq" ensures that we only consider files with the ".fastq" extension.
#-exec mv {} LarvalGE \; moves each found FASTQ file to the "LarvalGE" directory.
#-exec rmdir {} \; attempts to remove the empty directories (the ones that contained the FASTQ files).

ls *fastq* | wc 
#192 files
