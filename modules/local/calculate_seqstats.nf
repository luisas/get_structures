
process CALCULATE_SEQSTATS {
    tag "$meta.id"
    label 'process_low'

    container '/users/cn/lsantus/sing_cache/luisas-python-bio3.img'

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${meta.id}*seqstats.csv"), emit: seqstats
    tuple val(meta), path("${meta.id}*seqstats_summary.csv"), emit: seqstats_summary
    path "versions.yml" , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def id = meta.id
    """
    calc_seqstats.py $id ${fasta} "${prefix}_seqstats.csv" "${prefix}_seqstats_summary.csv"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}


