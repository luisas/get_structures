//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'
include { DBSHEET_CHECK } from '../../modules/local/dbsheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv
    dbsheet 
    
    main:

    ch_versions = Channel.empty()

    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fasta_channel(it) }
        .set { fastas }
    ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)   

    DBSHEET_CHECK ( dbsheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_db_channel(it) }
        .set { dbs }
    ch_versions = ch_versions.mix(DBSHEET_CHECK.out.versions)
    dbs.view()
    
    emit:
    fastas        
    dbs                             // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fasta_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.id

    // add path(s) of the fastq file(s) to the meta map
    def fasta_meta = []
    if (!file(row.fasta).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }

    fasta_meta = [ meta, file(row.fasta)  ]

    return fasta_meta
}

def create_db_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.id

    // add path(s) of the fastq file(s) to the meta map
    def db_meta = []
    db_meta = [ meta, file(row.db)  ]

    return db_meta
}