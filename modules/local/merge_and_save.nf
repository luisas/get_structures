


process MERGE_AND_SAVE{
    
    storeDir "${params.outdir}/$folder_name/"

    label "process_low"

    input:
    tuple val(meta),file(files)
    val(folder_name)
    val(extension)

    output:
    tuple val(meta), file("${meta.id}.${extension}"), emit: all_files

    script:
    """
    mkdir -p ${meta.id}
    for file in $files; do cat \$file >> ${meta.id}.${extension} ; done
    """
}