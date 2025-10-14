process CHECKINPUT {
    errorStrategy 'finish'
    tag "$pair_id"
    maxForks 2

    input:
        tuple val(pair_id), path(R1), path(R2)

    output:
        tuple val(pair_id), path("${pair_id}_stats.csv"), emit: stats
        tuple val(pair_id), path("${pair_id}_*_R1.fastq.gz"), path("${pair_id}_*_R2.fastq.gz"), emit: fastqreads

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
            fastq_subsample.py ${R1} ${R2} \$maxreads
            flag="DownSampled"
            num_raw=\$maxreads
        elif [[ \$raw_R1 -le \$maxreads ]] && [[ \$raw_R1 -ge \$minreads ]]; then
            mv ${R1} ${pair_id}_checked_R1.fastq.gz
            mv ${R2} ${pair_id}_checked_R2.fastq.gz
            num_raw=\$raw_R1
        elif [[ \$raw_R1 -lt \$minreads ]]; then
            flag="InsufficientData"
            mv ${R1} ${pair_id}_lowdata_R1.fastq.gz
            mv ${R2} ${pair_id}_lowdata_R2.fastq.gz
            num_raw=\$raw_R1
        fi

        # Write values to CSV file
        echo "Sample,Flag,NumRawReads" > "${pair_id}_stats.csv"
        echo "${pair_id},\$flag,\${num_raw}" >> "${pair_id}_stats.csv"
        """
}
