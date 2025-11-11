process SRST2_RECN {
    tag "$pairId"
    errorStrategy 'ignore'
    maxForks 1
    publishDir "${params.outdir}/Results_${params.dataDir}_${params.today}/recN", mode: "copy"

    input:
        tuple val(pairId), file(R1), file(R2)

    output:
	    tuple val(pairId), file("recN_${pairId}*_genes_*.txt"), emit: recN_genes
        tuple val(pairId), file("recN_*_fullgenes_*.txt"), optional: true, emit: recN_fullgenes
	
    script:
    """
    srst2.py --input_pe $R1 $R2 --forward _.*_R1 --reverse _.*_R2 --output recN_$pairId\
             --gene_db ${params.recN_ref} --max_unaligned_overlap 75 --log
    """
}