
process MMSEQS_CREATEALIS {
    tag "$meta.id"
    label 'process_medium'
    storeDir "${params.outdir}/mmseqs/id_${params.mmseqs_min_id}_cov_${params.mmseqs_min_cov}_covtype_${params.mmseqs_cov_type}_kmermatching_${params.mmseqs_exact_kmer_matching}/search_output"
    conda "bioconda::mmseqs2=14.7e284"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mmseqs2:14.7e284--pl5321h6a68c12_2':
        'biocontainers/mmseqs2:14.7e284--pl5321h6a68c12_2' }"

    input:
    tuple val(meta), path(db_result)
    tuple val(meta2), path(db_query)
    tuple val(meta3), path(db_target)

    output:
    tuple val(meta), path("${meta.id}.m8") , emit: hits
    //path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Extract files with specified args based suffix | remove suffix | isolate longest common substring of files
    DB_RESULT_PATH_NAME=\$(find -L "$db_result/" -maxdepth 1 -name "*.dbtype" | sed 's/\\.\\[^.\\]*\$//' | sed -e 'N;s/^\\(.*\\).*\\n\\1.*\$/\\1\\n\\1/;D' | sed 's/.dbtype//' )
    DB_QUERY_PATH_NAME=\$(find -L "$db_query/" -maxdepth 1 -name "*.dbtype" | sed 's/\\.\\[^.\\]*\$//' | sed -e 'N;s/^\\(.*\\).*\\n\\1.*\$/\\1\\n\\1/;D' | sed 's/.dbtype//' )
    DB_TARGET_PATH_NAME=\$(find -L "$db_target/" -maxdepth 1 -name "*.dbtype" | sed 's/\\.\\[^.\\]*\$//' | sed -e 'N;s/^\\(.*\\).*\\n\\1.*\$/\\1\\n\\1/;D' | sed 's/.dbtype//'  )

    mmseqs \\
        convertalis \\
        \$DB_QUERY_PATH_NAME \\
        \$DB_TARGET_PATH_NAME \\
        \$DB_RESULT_PATH_NAME \\
        ${prefix}.m8 \\
        $args \\
        --threads ${task.cpus} \\
        --compressed 1

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mmseqs: \$(mmseqs | grep 'Version' | sed 's/MMseqs2 Version: //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mmseqs: \$(mmseqs | grep 'Version' | sed 's/MMseqs2 Version: //')
    END_VERSIONS
    """
}