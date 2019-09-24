#!/usr/bin/bash

#SBATCH --cpus-per-task=20
#SBATCH --time=8:00:00
#SBATCH --mem=30G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o slamseq.out
#SBATCH -e slamseq.err
#SBATCH --job-name slamseq

OUT=$PWD/slamdunk_R7799_trimmed_ii2

# input files
files=/groups/bell/jiwang/Projects/Jorge/NGS_requests/R7799_slamseq/ngs_raw/FASTQs_trimmed/*.fastq 

REF=/groups/cochella/jiwang/scripts/slamseq/reference/mm10/genome.fa
FILTERBED=/groups/cochella/jiwang/scripts/slamseq/annotation/mm10_Annotation_BurkardT/170614custom_mESCannotation_mapping_Thomas.bed
BED=/groups/cochella/jiwang/scripts/slamseq/annotation/mm10_Annotation_BurkardT/170614custom_mESCannotation_counting_Thomas.bed

# echo $files
# parameters
RL=100
BQ=27
T=20

hostname

module load gcc/6.3.0-2.27
source activate slamdunk

slamdunk all -b $BED -fb $FILTERBED -r $REF -o $OUT -5 12 -t $T -rl $RL -n 100 -m -mbq $BQ -q --skip-sam ${files}
# alleyoop summary -o $OUT/summary.txt -t $OUT/count $OUT/filter/${files/.fastq/}*bam
