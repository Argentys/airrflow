process ADD_SEQID_OAS {
    tag "${meta.id}"
    label 'process_low'

    conda "conda-forge::biopython=1.81"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'biocontainers/biopython:1.81' }"

    input:
    tuple val(meta), path(gz_file)

    output:
    tuple val(meta), path("${meta.id}.tsv"), emit: tsv

    script:
    """
    # Call the specialized Python script to process the .gz file
    python3 addSequenceIdToOAS.py \\
        ${gz_file} \\
        ${meta.id}.tsv \\
    """
}
