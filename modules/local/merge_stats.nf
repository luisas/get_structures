

process MERGE_STATS {
    label 'process_low'

    container '/users/cn/lsantus/sing_cache/luisas-python-bio3.img'

    input:
    path(tcoffee_seqreformat_simtot)
    path(seqstats_summary)

    output:
    path '*.csv'       , emit: csv
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    merge_stats.py \
        "stats_summary_report.csv" \
        ${tcoffee_seqreformat_simtot} \
        ${seqstats_summary}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
