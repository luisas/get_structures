
process DOWNLOAD_STRUCTURE_AFDB {
    tag "$meta.id"
    label 'process_low'

    
    container '/users/cn/lsantus/sing_cache/luisas-python-bio3.img'

    input:
    tuple val(meta), path(ids_to_download)
    tuple val(meta), path(hits)
    tuple val(meta), path(template)

    output:
    tuple val(meta), path("*.pdb"), emit: pdbs
    tuple val(meta), path(template), emit: template

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    function validate_url(){
      if [[ `wget -S --spider \$1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; else echo "false";  fi
    }

    for id in \$(cat $ids_to_download); do url="https://alphafold.ebi.ac.uk/files/\$id.pdb"; if `validate_url \$url == "true"`; then wget \$url; else echo "\$id NOT FOUND"; fi ; done

    while read -r sequence sep fetched_structure; do cp "\$fetched_structure.pdb" "\${sequence#>}.pdb"; done < $template; 

    rm AF*.pdb

    # ----------------------------------------------------
    # Here cut them according to hits
    # ----------------------------------------------------
    cut_structures.py ${hits}
    [ -f ./cut_structures_tmp.sh ] && tr ', ' ' ' < cut_structures_tmp.sh > cut_structures.sh
    [ -f ./cut_structures.sh ] && bash ./cut_structures.sh
    rm temp.pdb

    # ----------------------------------------------------
    # Here check their actual percentage identity 
    # ----------------------------------------------------

    

    """

    stub:
    """
    touch "dummy.pdb"
    touch "dummy_template.txt"
    """
}