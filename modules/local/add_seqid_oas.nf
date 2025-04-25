process ADD_SEQID_OAS {
    tag "${meta.id}"
    label 'process_low'

    conda "conda-forge::biopython=1.81 conda-forge::pandas=2.2.2 conda-forge::python-gzip"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-7d8e418eb73acc6a80daea8e111c94cf19a4ecfd:a9ee25632c9b10bbb012da76e6eb539acca8f9cd-1' :
        'biocontainers/mulled-v2-7d8e418eb73acc6a80daea8e111c94cf19a4ecfd:a9ee25632c9b10bbb012da76e6eb539acca8f9cd-1' }"

    input:
    tuple val(meta), path(file)

    output:
    tuple val(meta), path("${meta.id}.tsv"), emit: tsv

    script:
    """
    python3  /bin/addSequenceIdToOAS.py \\
        ${file} \\
        ${meta.id}.tsv
    """
}
