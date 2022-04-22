#!/usr/bin/bash
#SBATCH --job-name="HISAT2"
#SBATCH --time=02:00:00
#SBATCH --mem=75GB
#SBATCH --qos=short
#SBATCH --cpus-per-task=16
#SBATCH --partition=c
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --array=1-2

ml load hisat2/2.1.0-foss-2018b
ml load samtools/1.10-foss-2018b
 
File=$(ls ngs_raw/FASTQs/*.fastq| head -n $SLURM_ARRAY_TASK_ID |tail -1)
BaseName=$(echo $File | sed 's/.*\///;s/\..*//')
outDir=$PWD/aligned
mkdir -p $outDir

hisat2 -p 16 --no-unal --summary-file ${ID}.log -k 5 --very-sensitive \
-x /groups/tanaka/Projects/axolotl-genome/current/work/annotation/indices/hisat2/AmexG_v6.DD.corrected.round2.chr \
-U ${File} \
| samtools view -@ 7 -b -h -O BAM -o ${outDir}/${BaseName}.bam
 
samtools sort -@ 15 -l 9 -m 2G ${outDir}/${BaseName}.bam > ${outDir}/${BaseName}.sort.bam
samtools index -@ 15 -c -m 14 ${outDir}/${BaseName}.sort.bam
