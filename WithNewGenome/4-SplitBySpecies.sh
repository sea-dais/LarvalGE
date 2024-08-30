#Use Split by Species.sh

#Create prefix list of all the files 
ls | cut -d'_' -f1 | sort -u > file_list.txt

nano CNAT_prefixlist.txt

python splitbyspecies.py CNAT_prefixlist.txt -i ./TrimmedFQ -o ./CNAT
