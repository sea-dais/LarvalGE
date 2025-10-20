#Download Illumina Basespace Command line interface
wget  "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O $HOME/bin/bs

#make it executable
chmod u+x $HOME/bin/bs
#Authenticate
## this command will give you link to copy into browser. Easier if you are already logged into basespace.
bs auth
## view list of your projects
bs list projects

#Download Files: Enter IDEV or send as a job !!
## change project name to yours
PROJECT = XX00000
bs -v download project --name $PROJECT --extension=fastq.gz

# Once everything is downloaded run the following command to move all the fastq files into one directory. 
# I downloaded the project into LarvalGE Directory, but want the fastq files not all the subdirectories 
## command to move all files up to main directory
find LarvalGE -mindepth 2 -type f -name "*.fastq.gz" -exec mv {} LarvalGE/ \;
## command to remove empty directories
find LarvalGE -mindepth 1 -type d -empty -delete

# Check number of files. 
ls | wc 
#192 files