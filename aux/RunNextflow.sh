
# Check if an argument was provided
if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one input file"
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Store input file in a clearer variable name
input_file="$1"

# Extract prefix before first dot with error checking
prefix=$(cut -f 1 -d "." <<< "$input_file" 2>/dev/null)
if [ -z "$prefix" ]; then
    echo "Error: Could not extract prefix from $input_file"
    exit 1
fi

# Run Python script with error checking
if ! python3 ../AddId.py "$input_file"; then
    echo "Error: Python script execution failed"
    exit 1
fi

# Change directory with error checking
working_dir="${prefix}.nextflow.dir"
if ! cd "$working_dir"; then
    echo "Error: Could not change to directory $working_dir"
    exit 1
fi

# Launch screen and Nextflow command
# Using exec to replace shell with screen process
#exec screen -dm bash -c "
    nextflow run Argentys/airrflow \
        -profile test,docker \
        --outdir O.dir \
        -w W.dir \
        --input input.tsv \
        -latest \
        --lineage_trees true \
#	--clonal_threshold spectral \
        -resume
#"
