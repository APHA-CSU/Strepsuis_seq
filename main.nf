#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* set modules */
include { KRAKENID } from './modules/krakenID'
include { SRST2_RECN } from './modules/srst2_recN'
include { SRST2_MLST } from './modules/srst2_mlst'
include { SRST2_SEROTYPE } from './modules/srst2_serotype'
include { SRST2_VIRULENCE } from './modules/srst2_virulence'
include { VERIFY_SEROTYPE } from './modules/verifySerotype'
include { COMBINE_OUTPUTS } from './modules/combineoutputs'

workflow {
    channel
        .fromFilePairs( params.reads, flat: true )
            .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
            .set { readPairs }

    //trim(readPairs)

    KRAKENID(
        readPairs,
        params.kraken2db,
        params.lowmem
        )
    SRST2_RECN(readPairs)
    SRST2_MLST(readPairs)
    SRST2_SEROTYPE(readPairs)
    SRST2_VIRULENCE(readPairs)
    SRST2_SEROTYPE.out.srst2_sero
        .join( readPairs )
        .set { verify_reads }
    VERIFY_SEROTYPE(verify_reads)
    SRST2_RECN.out.recN_genes
        .map { it -> it[1] }
        .collectFile( name: "recN_table.tsv", sort: true, keepHeader: true, storeDir: "${params.outdir}/Results_${params.dataDir}_${params.today}/recN" )
        .set { recN }
    SRST2_MLST.out
        .map { it -> it[1] }
        .collectFile( name: "mlst_table.tsv", sort: true, keepHeader: true, skip: 1, storeDir: "${params.outdir}/Results_${params.dataDir}_${params.today}/MLST" )
        .set { mlst }
    SRST2_SEROTYPE.out.serotype_results
        .map { it -> it[1] }
        .collectFile( name: "serotype_table.tsv", sort: true, keepHeader: true, skip: 1, storeDir: "${params.outdir}/Results_${params.dataDir}_${params.today}/serotype" )
        .set { serotype }
    SRST2_VIRULENCE.out.virulence_genes
        .map { it -> it[1] }
        .collectFile( name: "virulence_table.tsv", sort: true, keepHeader: true, skip: 1, storeDir: "${params.outdir}/Results_${params.dataDir}_${params.today}/virulence" )
        .set { virulence }
    VERIFY_SEROTYPE.out
        .map { it -> it[1] }
        .collectFile( name: "verification.csv", sort: true, keepHeader: true, skip: 1, storeDir: "${params.outdir}/Results_${params.dataDir}_${params.today}/serotype" )
        .set { verify }
    KRAKENID.out.krakenstats
        .map { it -> it[1] }
        .collectFile( name: "krakenID.csv", sort: true, keepHeader: true, skip: 1, storeDir: "${params.outdir}/Results_${params.dataDir}_${params.today}/krakenID" )
        .set { kraken }
    COMBINE_OUTPUTS(recN, mlst, serotype, virulence, verify, kraken)
}
