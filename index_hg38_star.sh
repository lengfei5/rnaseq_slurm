#!/usr/bin/bash

#SBATCH --cpus-per-task=8
#SBATCH --time=120
#SBATCH --mem=50000

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o genome_index.out
#SBATCH -e genome_index.err
#SBATCH --job-name index_hg38

module load star/2.5.2a-foss-2018b

Genome='/groups/cochella/jiwang/Genomes/Human/hg38/sequence/WholeGenomeFasta/genome.fa'
GTF='/groups/cochella/jiwang/Genomes/Human/hg38/annotation/Genes/genes.gtf'
OUT="/groups/cochella/jiwang/Genomes/Human/hg38/sequence/index_4star"

STAR --runMode genomeGenerate --runThreadN 8 --genomeDir $OUT --genomeFastaFiles $Genome --sjdbGTFfile $GTF
