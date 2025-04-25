process ADD_SEQID_OAS {
    tag "${meta.id}"
    label 'process_low'

    conda "conda-forge::biopython=1.81 conda-forge::pandas=2.2.2 conda-forge::python-gzip"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'biocontainers/biopython:1.81' }"

    input:
    tuple val(meta), path(file)

    output:
    tuple val(meta), path("${meta.id}.tsv"), emit: tsv

    script:
    """
    python3 addSequenceIdToOAS.py \\
        ${file} \\
        ${meta.id}.tsv
    """
}
