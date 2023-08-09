include { MMSEQS_EASYSEARCH } from '../../modules/nf-core/mmseqs/easysearch/main'                                                                                                                                        
include { STORE_FASTA_CHUNKS } from '../../modules/local/store_fasta_chunks.nf'
include { MERGE_AND_SAVE } from '../../modules/local/merge_and_save.nf'
include { FILTER_HITS    } from '../../modules/local/filter_hits.nf'


workflow DB_SEARCH {

    take: 
    ch_fastas
    target_db

    main: 
    ch_versions = Channel.empty()

    // 
    // Optionally prepare the input and chunk the input file
    //
    
    if(params.split_fasta){
        ch_fastas = ch_fastas.splitFasta( by: params.fasta_chunk_size, file: true )
        STORE_FASTA_CHUNKS(ch_fastas)
        ch_fastas = STORE_FASTA_CHUNKS.out.stored_file.map{
                                                            meta, fastafile -> 
                                                            def tmp = meta.clone()
                                                            tmp.group = tmp.id
                                                            tmp.id = tmp.id + "_" + fastafile.baseName.split("\\.")[1]
                                                            return [tmp, fastafile] 
                                                        }
    }



    // 
    // Search in database
    //
    ch_input_for_search = ch_fastas.combine(target_db)
                                .multiMap{
                                    meta, fastafile, metadb, dbfile ->
                                    fasta: [ meta, fastafile ]
                                    db: [ metadb, dbfile ]
                                }
    ch_input_for_search.fasta.view()
    ch_input_for_search.db.view()
    
    MMSEQS_EASYSEARCH ( ch_input_for_search.fasta, ch_input_for_search.db )
    hits = MMSEQS_EASYSEARCH.out.tsv
    ch_versions = ch_versions.mix(MMSEQS_EASYSEARCH.out.versions)

    // If we have split the fasta, we can merge the results
    if(params.split_fasta && params.mmseqs_save_merged){
        MERGE_AND_SAVE(hits.map{ meta, tsv -> [ [id: meta["group"]], tsv] }.groupTuple(by: 0), "mmseqs_merged", "tsv")
    }
    
    //
    // FILTER THE SEARCH: fetches the structures
    //
    FILTER_HITS (
        hits
    )
    ch_versions = ch_versions.mix(FILTER_HITS.out.versions)

    emit:
    filtered_hits = FILTER_HITS.out.filtered_hits
    versions = ch_versions.ifEmpty(null)

}
