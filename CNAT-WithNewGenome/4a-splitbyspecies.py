import os
import shutil
import argparse

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Copy files with specified prefixes.")
    parser.add_argument("prefix_file", help="Path to the prefix list file")
    parser.add_argument("-i", "--input", required=True, help="Input directory path")
    parser.add_argument("-o", "--output", required=True, help="Output directory path")
    
    args = parser.parse_args()

    # Assign arguments to variables
    prefix_list_filename = args.prefix_file
    input_directory = args.input
    output_directory = args.output

    # Read the list of prefixes from the specified file
    with open(prefix_list_filename, 'r') as prefix_file:
        prefixes = [line.strip() for line in prefix_file]

    # Create the output directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)

    # List all files in the input directory
    files = os.listdir(input_directory)

    # Iterate through the files and copy the ones with matching prefixes to the output directory
    for file in files:
        for prefix in prefixes:
            if file.startswith(prefix):
                source_path = os.path.join(input_directory, file)
                dest_path = os.path.join(output_directory, file)
                shutil.copy(source_path, dest_path)
                print(f"Copied: {file} to {output_directory}/{file}")

    print("Copy operation completed.")

if __name__ == "__main__":
    main()