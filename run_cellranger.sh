#!/usr/bin/bash
#SBATCH --export=ALL	
#SBATCH --qos=medium
#SBATCH --time=2-00:00:00
#SBATCH --partition=c
#SBATCH --mem=150G
#SBATCH --cpus-per-task=32
#SBATCH --ntasks=1 
#SBATCH -o logs/cellranger_counts.out
#SBATCH -e logs/cellranger_counts.err
#SBATCH --job-name cellranger

module load cellranger/5.0.1

cellranger count --id=E10_5H9 \
	   --fastqs=/groups/tanaka/People/current/jiwang/projects/limbRegeneration_scRNA/raw_NGS/mouse/raw/E10.5_H9 \
	   --sample=114344 \
	   --transcriptome=/groups/tanaka/People/current/jiwang/Genomes/Mouse/mm10_Ensemble/ens_mm10_10x \
	   --expect-cells=8000 \
	   --jobmode local \
	   --localcores=32 \
           --localmem=128

