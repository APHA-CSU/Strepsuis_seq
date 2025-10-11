process COMBINE_OUTPUTS {
    tag "combine"
    publishDir "${params.outdir}/Results_${params.dataDir}_${params.today}", mode: "copy"

    input:
        file("recN.tsv")
        file("MLST.tsv")
        file("serotype.tsv")
        file("virulence.tsv")
        file("verify.csv")

    output:
        file("*.csv")

    script:
    """
        combine_outputs.py recN.tsv MLST.tsv serotype.tsv virulence.tsv verify.csv ${params.dataDir}
    """
}
