
include { MMSEQS_CREATEDB } from '../../modules/nf-core/mmseqs/createdb/main'                                                                                                                                        
include { MMSEQS_SEARCH } from '../../modules/nf-core/mmseqs/search/main'
include { MMSEQS_CREATETSV } from '../../modules/nf-core/mmseqs/createtsv/main'                                                                                                                                      
include { MMSEQS_CREATEALIS } from '../../modules/local/mmseqs_createalis'                                                                                                                                      


workflow MMSEQS_SEARCH_WF {

    take: 
    ch_fastas
    target_db

    main: 
    ch_versions = Channel.empty()

    //
    // Prep db for query fasta file
    //
    MMSEQS_CREATEDB( ch_fastas )
    query_db = MMSEQS_CREATEDB.out.db
    //ch_versions = ch_versions.mix(MMSEQS_CREATEDB.out.versions)

    ch_input_for_search = query_db.combine(target_db)
                                   .multiMap{
                                        meta, fastafile, metadb, dbfile ->
                                        fasta: [ meta, fastafile ]
                                        db: [ metadb, dbfile ]
                                    }
    //
    // Search against target db
    //
    MMSEQS_SEARCH ( ch_input_for_search.fasta, ch_input_for_search.db )
    result_db = MMSEQS_SEARCH.out.db_search
    //ch_versions = ch_versions.mix(MMSEQS_SEARCH.out.versions)

    ch_input_for_search.fasta.combine(ch_input_for_search.db)
                        .combine(result_db, by:0 ).unique()
                        .multiMap{
                            meta, fastafile, metadb, dbfile, resultfile ->
                            fasta: [ meta, fastafile ]
                            db: [ metadb, dbfile ]
                            result: [ meta, resultfile ]
                        }.set{ ch_input_for_createtsv }


    //
    // Format results
    //
    MMSEQS_CREATEALIS( ch_input_for_createtsv.result, ch_input_for_createtsv.fasta, ch_input_for_createtsv.db  )     
    ch_versions = ch_versions.mix(MMSEQS_CREATEALIS.out.versions)

    // Create CSV
    MMSEQS_CREATETSV(  ch_input_for_createtsv.result, ch_input_for_createtsv.fasta, ch_input_for_createtsv.db)
    ch_versions = ch_versions.mix(MMSEQS_CREATETSV.out.versions)

    
    emit:
    hits     = MMSEQS_CREATEALIS.out.hits
    versions = ch_versions.ifEmpty(null)

}