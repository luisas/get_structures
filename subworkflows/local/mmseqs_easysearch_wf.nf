
include { MMSEQS_CREATEDB } from '../../modules/nf-core/mmseqs/createdb/main'                                                                                                                                        
include { MMSEQS_EASYSEARCH } from '../../modules/nf-core/mmseqs/easysearch/main'                                                                                                                                   


workflow MMSEQS_EASYSEARCH_WF {

    take: 
    ch_fastas
    target_db

    main: 
    ch_versions = Channel.empty()

    //
    // Prep db for query fasta file
    //
   

    ch_input_for_search = ch_fastas.combine(target_db)
                                   .multiMap{
                                        meta, fastafile, metadb, dbfile ->
                                        fasta: [ meta, fastafile ]
                                        db: [ metadb, dbfile ]
                                    }
    //
    // Search against target db
    //
    MMSEQS_EASYSEARCH ( ch_input_for_search.fasta, ch_input_for_search.db )
    //ch_versions = ch_versions.mix(MMSEQS_SEARCH.out.versions)


    
    emit:
    hits     = MMSEQS_EASYSEARCH.out.tsv
    versions = ch_versions.ifEmpty(null)

}