process IGTREE {
    tag "${meta.id}"
    label 'process_medium'
    label 'immcantation'

    container 'igortrue/immcantation:latest'

    input:
    tuple val(meta), path(tabs)      // meta, sequence tsv in AIRR format
    path clones_file                 // clone-pass.tsv from define_clones

    output:
    tuple val(meta), path("*_tree.txt"), emit: tree
    path "versions.yml", emit: versions

    script:
    """
    python3 igtree.py \\
        ${tabs} \\
        ${clones_file} \\
        > ${meta.id}_tree.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
    END_VERSIONS
    """
}
EOF