process KRAKENID {
	errorStrategy 'finish'
    tag "$pair_id"
	publishDir "$params.outdir/Results_${params.dataDir}_${params.today}/KrakenID", mode: 'copy', pattern: '*tab'
	maxForks 1
	
	input:
		tuple val(pair_id), path(R1), path(R2)
		val kraken2db
		val lowmem
	
	output:
		tuple val(pair_id), path("${pair_id}_brackensort.tab"), path("${pair_id}_kraken2.tab"), optional: true, emit: krakenOut
	
	script:
	"""
    # Error handling
    set -eo pipefail

    # Run Kraken2
        kraken2 --threads 2 --quick ${lowmem} --db ${kraken2db} --output - --report interim_kraken2.tab --paired ${R1} ${R2}

        # Process Kraken2 output
        sed 's/\\t\\t1\\troot/\\tR\\t1\\troot/g' interim_kraken2.tab |
        sed 's/\\t1\\t131567\\t/\\tR1\\t131567\\t/g' |
        sed 's/\\t\\t2\\t/\\tD\\t2\\t/g' > ${pair_id}_kraken2.tab

        # HACK: Ignore Bracken errors when read counts are low
        set +e

        # Run Bracken for level S
        bracken -d ${kraken2db} -r 150 -l S -t 10 -i ${pair_id}_kraken2.tab -o ${pair_id}_bracken.out
        sed 1d ${pair_id}_bracken.out | sort -t \$'\\t' -k7,7 -nr - | head -20 > ${pair_id}_brackensort.tab

        set -e

        # Extract Strep suis information
        SsPos=\$(grep -m 1 'Streptococcus suis' ${pair_id}_brackensort.tab |
        awk '{printf \$1" "\$2","\$7"," "%.3f", (\$8*100)}' || true)

        # Write Ssuis information to CSV
        echo "Sample,ID,TotalReads,Abundance" > "${pair_id}_Ssuis.csv"
        echo "${pair_id},\$SsPos" >> "${pair_id}_Ssuis.csv"

	"""
}
