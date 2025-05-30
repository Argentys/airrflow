def asString (args) {
    def s = ""
    def value = ""
    if (args.size()>0) {
        if (args[0] != 'none') {
            for (param in args.keySet().sort()){
                value = args[param].toString()
                if (!value.isNumber()) {
                    value = "'"+value+"'"
                }
                s = s + ",'"+param+"'="+value
            }
        }
    }
    return s
}

process DEFINE_CLONES {
    tag "${meta.id}"

    label 'process_long_parallelized'
//    label 'process_single'
    label 'immcantation'

    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "nf-core/airrflow currently does not support Conda. Please use a container profile instead."
    }
 //   container "docker.io/immcantation/airrflow:4.1.0"
    container 'igortrue/immcantation:latest'
    input:
    tuple val(meta), path(tabs) // meta, sequence tsv in AIRR format
    val threshold
    path reference_fasta
    path repertoires_samplesheet

    output:
    path("*/*/*clone-pass.tsv"), emit: tab // sequence tsv in AIRR format
    path("*/*_command_log.txt"), emit: logs //process logs
    path "*_report"
    path "versions.yml", emit: versions


    script:
    def args1 = task.ext.args ? asString(task.ext.args) : ''
    def args2 = task.ext.args2 ? asString(task.ext.args2) : ''
    def thr = threshold.join("")
    def args = ""
    if  (thr == 'spectral') {
        thr = 0.0
        args = args2
    }  else {
        args = args1
    }
    def input = ""
    if (repertoires_samplesheet) {
        input = repertoires_samplesheet
    } else {
        input = tabs.join(',')
    }
    """
    Rscript -e "enchantr::enchantr_report('define_clones', \\
                                        report_params=list('input'='${input}', \\
                                        'imgt_db'='${reference_fasta}', \\
                                        'species'='auto', \\
                                        'cloneby'='${params.cloneby}', \\
                                        'outputby'='${params.cloneby}', \\
                                        'force'=FALSE, \\
                                        'threshold'=${thr}, \\
                                        'singlecell'='${params.singlecell}', \\
                                        'outdir'=getwd(), \\
                                        'isotype_column'='${params.isotype_column}', \\
                                        'nproc'=${task.cpus}, \\
                                        'log'='${meta.id}_clone_command_log' ${args}))"

    cp -r enchantr ${meta.id}_clone_report && rm -rf enchantr

    echo "${task.process}": > versions.yml
    Rscript -e "cat(paste0('  enchantr: ',packageVersion('enchantr'),'\n'))" >> versions.yml
    """
}
