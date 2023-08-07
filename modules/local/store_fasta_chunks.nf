process STORE_FASTA_CHUNKS{

    storeDir "${params.outdir}/fasta_chunks/${meta.id}/${params.fasta_chunk_size}/"
    label "process_low"

    input:
    tuple val(meta), file(file)

    output:
    tuple val(meta), file("dir/$file"), emit:  stored_file
    
    script:
    """
    mkdir -p dir
    cp $file dir/
    """
}

