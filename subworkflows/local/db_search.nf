include { MMSEQS_CREATEDB } from '../../modules/nf-core/mmseqs/createdb/main'                                                                                                                                        
include { MMSEQS_SEARCH } from '../../modules/nf-core/mmseqs/search/main'
include { MMSEQS_CREATETSV } from '../../modules/nf-core/mmseqs/createtsv/main'                                                                                                                                      
include { MMSEQS_CREATEALIS } from '../../modules/local/mmseqs_createalis'                                                                                                                                      
include { MMSEQS_EASYSEARCH } from '../../modules/local/mmseqs_easysearch'                                                                                                                                        

workflow DB_SEARCH {

    take: 
    ch_fastas
    target_db

    main: 
    ch_versions = Channel.empty()

    MMSEQS_EASYSEARCH ( ch_fastas, target_db )
    ch_versions = ch_versions.mix(MMSEQS_EASYSEARCH.out.versions)
    
    //
    // Prep db for query fasta file
    //
    // MMSEQS_CREATEDB( ch_fastas )
    // query_db = MMSEQS_CREATEDB.out.db
    // ch_versions = ch_versions.mix(MMSEQS_CREATEDB.out.versions)

    // ch_input_for_search = query_db.combine(target_db)
    //                                .multiMap{
    //                                     meta, fastafile, metadb, dbfile ->
    //                                     fasta: [ meta, fastafile ]
    //                                     db: [ metadb, dbfile ]
    //                                 }
    
    // MMSEQS_SEARCH ( ch_input_for_search.fasta, ch_input_for_search.db )
    // result_db = MMSEQS_SEARCH.out.db_search
    // ch_versions = ch_versions.mix(MMSEQS_SEARCH.out.versions)

    

    // ch_input_for_search.fasta.combine(ch_input_for_search.db)
    //                     .combine(result_db, by:0 )
    //                     .multiMap{
    //                         meta, fastafile, metadb, dbfile, resultfile ->
    //                         fasta: [ meta, fastafile ]
    //                         db: [ metadb, dbfile ]
    //                         result: [ meta, resultfile ]
    //                     }.set{ ch_input_for_createtsv }


    // MMSEQS_CREATEALIS ( ch_input_for_createtsv.result, ch_input_for_createtsv.fasta, ch_input_for_createtsv.db  )            


    emit:
    versions = ch_versions.ifEmpty(null)

}