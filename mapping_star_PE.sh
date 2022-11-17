######################################
# mapping paired-end fastq files with star 
######################################
DIR_input="${PWD}/ngs_raw/FASTQs"
outDir="${PWD}/alignment"

mkdir -p $outDir
mkdir -p "${PWD}/logs"

jobName='star'

for seq1 in `ls ${DIR_input}/*.fastq | grep "_R1"`;
do
    fname="$(basename $seq1)"
    SUFFIX=${fname#*_R1}
    fname=${fname%_R1*}
    
    seq2=${DIR_input}/${fname}_R2${SUFFIX};
    echo $seq1
    echo $seq2
    echo $fname
    
    # creat the script for each sample
    script=${PWD}/logs/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash
#SBATCH --job-name=$jobName
#SBATCH --time=04:00:00
#SBATCH --mem=64GB
#SBATCH --qos=short
#SBATCH --cpus-per-task=16
#SBATCH --partition=c
#SBATCH --output=${PWD}/logs/$fname.out
#SBATCH --error=${PWD}/logs/$fname.err

#ml load star/2.7.1a-foss-2018b
ml load star/2.5.2a-foss-2018b
ml load samtools/1.10-foss-2018b
 
STAR --genomeDir /groups/tanaka/People/current/jiwang/Genomes/mouse/mm10_ens/index_4star \
--runThreadN 16 \
--readFilesIn $seq1 $seq2 \
--outFileNamePrefix ${outDir}/${fname} \
--outSAMtype BAM Unsorted

samtools sort -o ${outDir}/${fname}.bam ${outDir}/${fname}Aligned.out.bam
samtools index ${outDir}/${fname}.bam
rm ${outDir}/${fname}Aligned.out.bam

EOF
    
    cat $script;
    sbatch $script
    
    #break;

done
