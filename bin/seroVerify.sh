#!/bin/bash

set -eo pipefail

index=$1
read1=$2
read2=$3
sample=$4
serotype=$5

if [[ "$serotype" == "1" || "$serotype" == "1*" || "$serotype" == "1*?" || "$serotype" == "2" || "$serotype" == "2*" || "$serotype" == "2*?" ]]; then
    # map to cps2K
    bowtie2 -x $index -1 $read1 -2 $read2 -a --very-sensitive-local --no-unal |
        samtools view -S1 - | samtools sort - sorted

    # create vcf for cps2K
    samtools mpileup -DBuf $index.fas sorted.bam | bcftools view -c - > "$sample"_cps2K.vcf 

    # extract basecall and  evidence from vcf
    vcf483=$(awk '{if ($2 == "483") print $0}' "$sample"_cps2K.vcf) # extract full line
    ref483=$(echo $vcf483 | awk '{print $4}')
    alt483=$(echo $vcf483 | awk '{print $5}' | awk -F ',' '{print $1}')
    evidence=$(echo $vcf483 | grep -o 'DP4=[0-9]*,[0-9]*,[0-9]*,[0-9]*' | awk -F '=' '{print $2}')
   
    if [ $alt483 = '.' ]; then
        base483=$ref483
    else
        base483=$alt483
    fi

    echo "Sample,Pos483,RefF,RefR,AltF,AltR" > "$sample"_seroVerify.csv
    echo "$sample","$base483","$evidence" >> "$sample"_seroVerify.csv

else
    echo "Verification not required"
fi
