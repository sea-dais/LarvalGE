#!/bin/bash

# Check if a directory argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Set the directory path from the command-line argument
DIR="$1"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

# Rest of the script remains the same
files=($(find "$DIR" -name "*ReadsPerGene.out.tab"))

# Check if files were found
if [ ${#files[@]} -eq 0 ]; then
    echo "No ReadsPerGene.out.tab files found in $DIR"
    exit 1
fi

# Create a temporary file for the header
temp_header=$(mktemp)

# Create the header
## Removes .trim.fastq_ReadsPerGene.out.tab from file name

echo -n "GeneID" > "$temp_header"
for file in "${files[@]}"; do
    basename=$(basename "$file" | sed 's/.trim.fastq_ReadsPerGene.out.tab//')
    echo -n $'\t'"$basename" >> "$temp_header"
done
echo "" >> "$temp_header"

# Create a temporary file for the data
temp_data=$(mktemp)

# Process each file
awk 'FNR>4 {
    if (NR==FNR) {
        id[$1]=$1; count[$1]=$2
    } else {
        count[$1]=count[$1]"\t"$2
    }
}
END {
    for (i in id) {
        print id[i]"\t"count[i]
    }
}' "${files[@]}" > "$temp_data"

# Combine header and data
cat "$temp_header" "$temp_data" > "counts.txt"

# Clean up temporary files
rm "$temp_header" "$temp_data"

echo "Output written to counts.txt"

# Display first 10 lines and 5 columns of the output
echo "First 10 lines and 5 columns of the output:"
head -n 10 "counts.txt" | cut -f 1-5