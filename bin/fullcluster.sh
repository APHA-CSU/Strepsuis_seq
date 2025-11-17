#!/bin/bash

set -eo pipefail

sample=$1
read1=$2
read2=$3
clusterRef=$4

# map to reference cps cluster sequences (https://journals.asm.org/doi/10.1128/aem.03742-12#T1)
bwa mem -M -E 2 -t3 $clusterRef $read1 $read2 |
    samtools sort -@2 |
    samtools view -@3 -o $sample.bam

# determine depth for each position
samtools depth -a $sample.bam > "$sample"_depth.txt

# get mapping stats for each cps cluster
for var in $(awk '{print $1}' "$sample"_depth.txt | uniq);
    do
        avdepth=$(grep -E "$var\s" "$sample"_depth.txt | awk '{sum+=$3} END {print (sum/NR)}')
        nocov=$(grep -E "$var\s" "$sample"_depth.txt | awk '$3<1 {c++} END {print (c/NR)}')
        echo "$var","$avdepth","$nocov" >> "$sample"_mapSummary.csv
    done

echo Cluster,MeanDepth,NoCoverage > "$sample"_clusterMappingSorted.csv
sort -t, -k3,3 "$sample"_mapSummary.csv >> "$sample"_clusterMappingSorted.csv

rm "$sample"_depth.txt
rm "$sample"_mapSummary.csv
