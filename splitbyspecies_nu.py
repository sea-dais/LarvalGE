import os
import shutil

# Specify the variable for the prefix list filename.
prefix_list_filename = 'CNAT_prefixlist.txt'

# Read the list of prefixes from the specified file, filtering out empty lines
with open(prefix_list_filename, 'r') as prefix_file:
    prefixes = [line.strip() for line in prefix_file if line.strip()]  # Only keep non-empty lines

# Debug: Print the prefixes to verify
print(f"Found {len(prefixes)} prefixes:")
for prefix in prefixes:
    print(f"  '{prefix}'")

# Specify the input directory and output directory as variables.
input_directory = '/scratch/08717/dmflores/LarvalGE/TrimmedFQ'
output_directory = '/scratch/08717/dmflores/LarvalGE/CNAT'

# Create the output directory if it doesn't exist.
os.makedirs(output_directory, exist_ok=True)

# List all files in the input directory.
files = os.listdir(input_directory)

# Iterate through the files and copy the ones with matching prefixes to the output directory.
copied_count = 0
for file in files:
    for prefix in prefixes:
        if file.startswith(prefix):
            source_path = os.path.join(input_directory, file)
            dest_path = os.path.join(output_directory, file)
            shutil.copy(source_path, dest_path)
            print(f"Copied: {file}")
            copied_count += 1
            break  # Stop checking other prefixes once we find a match

print(f"\nCopy operation completed. Copied {copied_count} files.")