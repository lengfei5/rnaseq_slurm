#!/usr/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --qos=medium
#SBATCH --time=0-12:00:00
#SBATCH --partition=c
#SBATCH --mem=64G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o genome_index.out
#SBATCH -e genome_index.err
#SBATCH --job-name index_zebrafish

ml load star/2.7.1a-foss-2018b

Genome='/groups/tanaka/People/current/jiwang/Genomes/zebrafish/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa'
GTF='/groups/tanaka/People/current/jiwang/Genomes/zebrafish/GRCz11/Danio_rerio.GRCz11.106.gtf.gz'

OUT=${PWD}/GRCz11
mkdir -p $OUT

STAR --runMode genomeGenerate \
     --runThreadN 16 \
     --genomeDir $OUT \
     --genomeFastaFiles $Genome \
     --sjdbGTFfile $GTF
