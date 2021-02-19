#!/usr/bin/env bash
#SBATCH --job-name="rseqc"
#SBATCH --time=08:00:00
#SBATCH --mem=64GB
#SBATCH --qos=short
#SBATCH --cpus-per-task=16
#SBATCH --partition=c
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --array=1-12

ml load rseqc/2.6.5-foss-2018b-python-2.7.15
mkdir -p $PWD/saturation_rseqc

bed='/groups/tanaka/People/current/jiwang/Genomes/axolotl/annotations/ax6_UCSC_2021_01_26.bed'

File=$(ls /scratch/jiwang/Akane_R10724/nf_out_RNAseq/HISAT2/aligned_sorted/*.bam| head -n $SLURM_ARRAY_TASK_ID |tail -1)
BaseName=$(echo $File | sed 's/.*\///;s/\..*//')

junction_saturation.py -i $File -r $bed -o $PWD/saturation_rseqc/${BaseName}_junction

RPKM_saturation.py -r $bed -d '1++,1--,2+-,2-+' -i $File -o $PWD/saturation_rseqc/${BaseName}_rpkm

