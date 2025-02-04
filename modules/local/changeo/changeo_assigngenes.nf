process CHANGEO_ASSIGNGENES {
    tag "$meta.id"
    label 'process_high'
    label 'immcantation'
//bioconda::changeo=1.3.0 
//
    conda "bioconda::igblast=1.22.0 conda-forge::wget=1.20.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-7d8e418eb73acc6a80daea8e111c94cf19a4ecfd:a9ee25632c9b10bbb012da76e6eb539acca8f9cd-1' :
        'biocontainers/mulled-v2-7d8e418eb73acc6a80daea8e111c94cf19a4ecfd:a9ee25632c9b10bbb012da76e6eb539acca8f9cd-1' }"

    input:
    tuple val(meta), path(reads) // reads in fasta format
    path(igblast) // igblast references

    output:
    path("*igblast.fmt7"), emit: blast
    tuple val(meta), path("$reads"), emit: fasta
    path "versions.yml" , emit: versions
    path("*_command_log.txt"), emit: logs //process logs

    script:

    def args = task.ext.args ?: ''
    """
# Install Miniconda on the fly
    echo "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p /tmp/miniconda
    export PATH=/tmp/miniconda/bin:$PATH
    rm /tmp/miniconda.sh

    # Set custom Conda prefix and environment paths to avoid permission issues
    export CONDA_PREFIX=/tmp/miniconda
    export CONDA_ENVS_PATH=/tmp/miniconda/envs
    export CONDA_PKGS_DIRS=/tmp/miniconda/pkgs

    # Set HOME to /tmp to avoid user permission issues
    export HOME=/tmp

    # Ensure that Conda doesn't try to create directories in a restricted location
    export CONDA_CONFIG_DIR=/tmp/.conda-config

    # Initialize Conda
    source /tmp/miniconda/etc/profile.d/conda.sh

    # Install dependencies using Conda
    conda install -y git

    # Clone ChangeO repository and install
    git clone https://github.com/igortru/changeo.git /tmp/changeo
    cd /tmp/changeo

    AssignGenes.py igblast -s $reads -b $igblast --organism $meta.species --loci ${meta.locus.toLowerCase()} $args --nproc $task.cpus --outname $meta.id > ${meta.id}_changeo_assigngenes_command_log.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        igblastn: \$( igblastn -version | grep -o "igblast[0-9\\. ]\\+" | grep -o "[0-9\\. ]\\+" )
        changeo: \$( AssignGenes.py --version | awk -F' '  '{print \$2}' )
    END_VERSIONS
    """
}
