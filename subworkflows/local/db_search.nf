include { MMSEQS_CREATEDB } from '../../modules/nf-core/mmseqs/createdb/main'                                                                                                                                        
include { MMSEQS_SEARCH } from '../../modules/nf-core/mmseqs/search/main'
 include { MMSEQS_CREATETSV } from '../../modules/nf-core/mmseqs/createtsv/main'                                                                                                                                      


workflow DB_SEARCH {

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
    ch_versions = ch_versions.mix(MMSEQS_CREATEDB.out.versions)

    ch_input_for_search = query_db.combine(target_db)
                                   .multiMap{
                                        meta, fasta, metadb, db ->
                                        fasta: [ meta, fasta ]
                                        db: [ metadb, db ]
                                    }
    
    MMSEQS_SEARCH ( ch_input_for_search.fasta, ch_input_for_search.db )
    result_db = MMSEQS_SEARCH.out.db_search
    ch_versions = ch_versions.mix(MMSEQS_SEARCH.out.versions)

    

    ch_input_for_search.fasta.combine(ch_input_for_search.db)
                        .combine(result_db)
                        .multiMap{
                            meta, fasta, metadb, db, metares, result ->
                            fasta: [ meta, fasta ]
                            db: [ metadb, db ]
                            result: [ metares, result ]
                        }.set{ ch_input_for_createtsv }

    ch_input_for_createtsv.fasta.view()
    ch_input_for_createtsv.db.view()
    ch_input_for_createtsv.result.view()

    MMSEQS_CREATETSV ( ch_input_for_createtsv )            


    emit:
    versions = ch_versions.ifEmpty(null)

}