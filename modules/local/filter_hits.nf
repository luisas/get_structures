process FILTER_HITS {
    tag "$hits"
    label 'process_low'

    container '/users/cn/lsantus/sing_cache/luisas-python-bio3.img'


    input:
    tuple val(meta), file(hits)


    output:
    tuple val(meta), file("*_filtered_hits.m8")   , emit: filtered_hits
    tuple val(meta), file("*_ids_to_download.txt"), emit: ids_to_download
    tuple val(meta), file("*_template.txt")       , emit: template
    path "versions.yml", emit: versions


    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    filter_hits.py \\
        ${hits} \\
        "${prefix}_filtered_hits.m8" \\
        "${prefix}_template.txt" \\
        "${prefix}_ids_to_download.txt" \\
        "${prefix}_chains.txt" \\
        $args
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}