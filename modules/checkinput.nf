process CHECKINPUT {
    errorStrategy 'finish'
    tag "$pair_id"
    maxForks 2

    input:
        tuple val(pair_id), path(R1), path(R2)

    output:
        tuple val(pair_id), path("${pair_id}_stats.csv"), emit: stats
        tuple val(pair_id), path("${pair_id}_checked_R1.fastq.gz"), path("${pair_id}_checked_R2.fastq.gz"), optional: true, emit: fastqreads

    script:

        """
        # Error handling
        set -eo pipefail

        # Define thresholds for subsampling and flag assignment
            minreads=300000
            maxreads=800000

        # Count reads in each category; in fastq files each read consists of four lines
        raw_R1=\$(( \$(zcat ${R1} | wc -l) / 4 ))
        
        # Random subsample of large files
        if [[ \$raw_R1 -gt \$maxreads ]]; then
            fastq_subsample.py ${R1} ${R2} \$maxreads &&
            flag="DownSampled"
        elif [[ \$raw_R1 -le \$maxreads ]] && [[ \$raw_R1 -ge \$minreads ]]; then
            TODO: rename input
        else [[ \$raw_R1 -lt \$minreads ]]; then
            flag="InsufficientData"



        # Write values to CSV file
        echo "Sample,NumRawReads,NumDedupReads,%afterDedup,NumTrimReads,%afterTrim,NumMappedReads,%Mapped,MeanDepth,GenomeCov,Outcome" > "${pair_id}_stats.csv"
        echo "${pair_id},\${num_raw},\${num_uniq},\${pc_aft_dedup},\${num_trim},\${pc_aft_trim},\${num_map},\${pc_mapped},\${avg_depth},\${genome_cov},\${flag}" >> "${pair_id}_stats.csv"
        echo "\${flag}" > "${pair_id}_outcome.txt"
        """
}
