FROM ubuntu:24.04

####################### METADATA ##########################
LABEL Maintainer="Richard Ellis <richard.ellis@apha.gov.uk>"
LABEL base.image=ubuntu:24.04
LABEL software="Strepsuis_seq"
LABEL about.documentation="https://github.com/APHA-CSU/Strepsuis_seq"

#################### INSTALL BASICS #######################

RUN apt-get update && apt-get install --yes --no-install-recommends \
    wget \
    curl \
    unzip \
    bzip2 \
    gawk \
    gcc \
    git \
    build-essential \
    make
RUN apt-get install --yes --no-install-recommends \
    python3-dev \
    python3-pip \
    python3-pandas \
    python3-numpy \
    python3-scipy \
    python-is-python3
RUN apt-get install --yes --no-install-recommends \
    zlib1g-dev \
    libncurses-dev \
    liblzma-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    bowtie2

################## INSTALL DEPENDENCIES ###################

WORKDIR /home/tools

## install trimming tool
# RUN wget https://sourceforge.net/projects/bbmap/files/BBMap_39.11.tar.gz --no-check-certificate && \
#    tar -xvzf BBMap_39.11.tar.gz && rm -f BBMap_39.11.tar.gz

# ENV PATH="$PATH:/home/tools/bbmap"

## install samtools-0.1.18
RUN wget https://sourceforge.net/projects/samtools/files/samtools/0.1.18/samtools-0.1.18.tar.bz2 --no-check-certificate && \
    tar -xjvf samtools-0.1.18.tar.bz2 && rm -f samtools-0.1.18.tar.bz2 && \
    cd samtools-0.1.18/ && make && cd ..

ENV PATH="$PATH:/home/tools/samtools-0.1.18/"
ENV PATH="$PATH:/home/tools/samtools-0.1.18/bcftools/"

## install kraken, bracken and databases
RUN wget http://github.com/DerrickWood/kraken2/archive/v2.0.8-beta.tar.gz --no-check-certificate && \
    tar xzf v2.0.8-beta.tar.gz && \
    rm -f v2.0.8-beta.tar.gz && \
    cd kraken2-2.0.8-beta && \
    ./install_kraken2.sh ../Kraken2 && \
    cd ..  && \
    ln -s $PWD/Kraken2/kraken2 /usr/local/bin/kraken2

RUN mkdir -p /opt/Kraken2/db  && \
    wget https://genome-idx.s3.amazonaws.com/kraken/minikraken2_v1_8GB_201904.tgz -nv --no-check-certificate && \
    tar xvf minikraken2_v1_8GB_201904.tgz -C /opt/Kraken2/db/  && \
    rm -f minikraken2_v1_8GB_201904.tgz

RUN mkdir -p /opt/Kraken2/test-db  && \
    wget https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20250402.tar.gz -nv --no-check-certificate && \
    tar xvf k2_viral_20250402.tar.gz -C /opt/Kraken2/test-db/ && \
    rm -f k2_viral_20250402.tar.gz

RUN wget https://github.com/jenniferlu717/Bracken/archive/refs/tags/v3.1.tar.gz --no-check-certificate && \
    tar xvf v3.1.tar.gz && \
    rm -f v3.1.tar.gz && \
    cd Bracken-3.1/ && \
    sh ./install_bracken.sh && \
    cd .. && \
    ln -s $PWD/Bracken-3.1/bracken /usr/local/bin/bracken

WORKDIR /home
