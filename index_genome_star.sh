#!/usr/bin/bash

#SBATCH --cpus-per-task=32
#SBATCH --qos=medium
#SBATCH --time=2-00:00:00
#SBATCH --partition=c
#SBATCH --mem=150G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o genome_index.out
#SBATCH -e genome_index.err
#SBATCH --job-name index_ax6

module load star/2.5.2a-foss-2018b

Genome='/groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexG_v6.DD.corrected.round2.chr.fa'
GTF='/groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexT_v47.release.gtf'
OUT=${PWD}/ax6
mkdir -p ${PWD}/ax6

STAR --runMode genomeGenerate --runThreadN 32 --genomeDir $OUT --genomeFastaFiles $Genome --sjdbGTFfile $GTF --limitGenomeGenerateRAM 161061273600 --genomeSAsparseD 2
