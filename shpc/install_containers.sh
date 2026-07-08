#!/bin/bash
shpc_dir=/camber/home/tools/shpc/singularity-hpc
cd $shpc_dir
source .pyenv/bin/activate
shpc --version
shpc view list
shpc_install="shpc install -f "
$shpc_install quay.io/biocontainers/bwa
$shpc_install quay.io/biocontainers/samtools
$shpc_install quay.io/biocontainers/bcftools
$shpc_install quay.io/biocontainers/bedtools
$shpc_install quay.io/biocontainers/vcftools
$shpc_install quay.io/biocontainers/bowtie2
$shpc_install quay.io/biocontainers/blast
$shpc_install quay.io/biocontainers/fastqc
$shpc_install quay.io/biocontainers/trimmomatic
$shpc_install quay.io/biocontainers/star
$shpc_install quay.io/biocontainers/hisat2
$shpc_install quay.io/biocontainers/gatk4
$shpc_install quay.io/biocontainers/picard
$shpc_install quay.io/biocontainers/freebayes
$shpc_install quay.io/biocontainers/spades
$shpc_install quay.io/biocontainers/prokka
$shpc_install quay.io/biocontainers/quast
$shpc_install quay.io/biocontainers/biobb_amber
$shpc_install quay.io/biocontainers/portcullis
$shpc_install quay.io/biocontainers/slow5tools
