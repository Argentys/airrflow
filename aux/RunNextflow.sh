if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file gz> <output_dir>"
    exit 1
fi

script_dir=$(dirname "$(realpath "$0")")
input_file="$1"

# Extract prefix before first dot with error checking
prefix=$(cut -f 1 -d "." <<< "$input_file" 2>/dev/null)
if [ -z "$prefix" ]; then
    echo "Error: Could not extract prefix from $input_file"
    exit 1
fi

working_dir="${prefix}.nextflow.dir"

if [ -n "$2" ]; then
    working_dir="$2"
fi

# Run Python script with error checking
if ! python3 $script_dir/addSequenceId.py "$input_file" "$working_dir"; then
    echo "Error: Python script execution failed"
    exit 1
fi

if ! cd "$working_dir"; then
    echo "Error: Could not change to directory $working_dir"
    exit 1
fi

# Launch screen and Nextflow command
# Using exec to replace shell with screen process
#exec screen -dm bash -c "
    nextflow -quiet run Argentys/airrflow \
        -profile test,docker \
        --outdir O.dir \
        -w W.dir \
        --input input.tsv \
        -latest \
        --lineage_trees false \
#	--clonal_threshold spectral \
        -resume 
#"
