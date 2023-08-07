include { MMSEQS_EASYSEARCH } from '../../modules/nf-core/mmseqs/easysearch/main'                                                                                                                                        

workflow DB_SEARCH {

    take: 
    ch_fastas
    target_db

    main: 
    ch_versions = Channel.empty()
    ch_input_for_search = ch_fastas.combine(target_db)
                                   .multiMap{
                                        meta, fastafile, metadb, dbfile ->
                                        fasta: [ meta, fastafile ]
                                        db: [ metadb, dbfile ]
                                    }

    MMSEQS_EASYSEARCH ( ch_input_for_search.fasta, ch_input_for_search.db )
    ch_versions = ch_versions.mix(MMSEQS_EASYSEARCH.out.versions)
    


    emit:
    versions = ch_versions.ifEmpty(null)

}