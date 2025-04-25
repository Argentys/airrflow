process ADD_SEQID_OAS {
    tag "${meta.id}"
    label 'process_low'

    conda "conda-forge::biopython=1.81 conda-forge::pandas=2.2.2 conda-forge::python-gzip"
    container 'igortrue/immcantation:latest'

    input:
    tuple val(meta), path(file)

    output:
    tuple val(meta), path("${meta.id}.tsv"), emit: tsv

    script:
    """
        addSequenceIdToOAS.py \\
        ${file} \\
        ${meta.id}.tsv
    """
}
