[![Strepsuis_seq nf-test](https://github.com/aphascience/Strepsuis_seq/actions/workflows/maintest.yml/badge.svg)](https://github.com/aphascience/Strepsuis_seq/actions/workflows/maintest.yml)


# Strepsuis_seq

This is the repo for APHA's Nextflow implementation of the [_Streptococcus suis_ serotyping pipeline](https://github.com/streplab/SsuisSerotyping_pipeline).  It essentially makes use of SRST2 to map reads to mlst, virulence and serotyping databases. To reduce running time input files are downsampled if required and Kraken2 is used to confirm species ID alongside the presence of a recN allele thought to be species specific.  Some serotypes can only be differentiated based on a single SNP and this is achived using a bespoke module.

Calculations of best match are in the [SRST2 publication](
https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-014-0090-6)

srst2 processes are run in parallel and all data are collated onto a final output file.

```mermaid
flowchart TB
  subgraph " "
    subgraph params
      v0["reads"]
    end
    v2([CHECKINPUT])
    v5([KRAKENID])
    v6([SRST2_RECN])
    v7([SRST2_MLST])
    v8([SRST2_SEROTYPE])
    v9([SRST2_VIRULENCE])
    v11([VERIFY_SEROTYPE])
    v22([COMBINE_OUTPUTS])
    v0 --> v2
    v2 --> v5
    v2 --> v6
    v2 --> v7
    v2 --> v8
    v2 --> v9
    v0 --> v11
    v8 --> v11
    v2 --> v22
    v5 --> v22
    v6 --> v22
    v7 --> v22
    v8 --> v22
    v9 --> v22
    v11 --> v22
  end

```

_Streptococcus suis_ MLST database last updated 01-Oct-25 from: [_Streptococcus suis_ pubMLST](https://pubmlst.org/organisms/streptococcus-suis)

