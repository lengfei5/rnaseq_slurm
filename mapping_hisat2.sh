#!/usr/bin/env bash
#SBATCH --job-name="HISAT2"
#SBATCH --time=02:00:00
#SBATCH --mem=75GB
#SBATCH --qos=short
#SBATCH --cpus-per-task=8
#SBATCH --partition=c
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --array=1-6
module load hisat2/2.1.0-foss-2018b
module load samtools/1.10-foss-2018b
 
File=$(ls ../polyA_Removal/*fq.gz| head -n $SLURM_ARRAY_TASK_ID |tail -1)
BaseName=$(echo $File | sed 's/.*\///;s/\..*//')
 
hisat2 -p 16 --no-unal --summary-file ${ID}.log -k 5 --very-sensitive \
-x /groups/tanaka/Projects/axolotl-genome/current/work/annotation/indices/hisat2/AmexG_v6.DD.corrected.round2.chr \
-U ${File} \
| samtools view -@ 7 -b -h -O BAM -o ${BaseName}.bam
 
samtools sort -@ 15 -l 9 -m 2G ${BaseName}.bam > ${BaseName}.sort.bam
samtools index -@ 15 -c -m 14 ${BaseName}.sort.bam
