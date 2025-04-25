process ADD_SEQID_OAS {
    tag "${meta.id}"
    label 'process_low'

    conda "conda-forge::biopython=1.81 conda-forge::pandas=2.2.2 conda-forge::python-gzip"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multipackage:biopython-1.81-pandas-2.2.2' :
        'quay.io/biocontainers/multipackage:biopython-1.81-pandas-2.2.2' }"

    input:
    tuple val(meta), path(gz_file)
    path script_file, stageAs: 'addSequenceIdToOAS.py'

    output:
    tuple val(meta), path("${meta.id}.tsv"), emit: tsv

    script:
    """
    echo "Processing ${gz_file} for sample ${meta.id}" >&2
    if [[ ! -s ${gz_file} ]]; then
        echo "ERROR: Input file ${gz_file} is empty or does not exist" >&2
        exit 1
    fi
    if [[ ! -s addSequenceIdToOAS.py ]]; then
        echo "ERROR: Script addSequenceIdToOAS.py not found" >&2
        exit 1
    fi
    python3 addSequenceIdToOAS.py \\
        ${gz_file} \\
        ${meta.id}.tsv
    if [[ ! -s ${meta.id}.tsv ]]; then
        echo "ERROR: Output file ${meta.id}.tsv was not created or is empty" >&2
        exit 1
    fi
    echo "Successfully created ${meta.id}.tsv" >&2
    """
}
