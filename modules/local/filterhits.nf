process FILTER_HITS {
    tag "$samplesheet"
    label 'process_low'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'biocontainers/python:3.8.3' }"

    input:
    tuple val(meta), file(hits)


    output:
    tuple val(meta), file("${prefix}_filtered_hits.m8"), emit: filtered_hits


    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    filter_hits.py \\
        ${hits} \\
        "${id}_filtered_hits.m8" \\
        "${id}_template.txt" \\
        "${id}_ids_to_download.txt" \\
        "${id}_chains.txt" \\
        $args
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}