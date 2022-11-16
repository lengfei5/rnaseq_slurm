###################
## deduplicate reads integrated with umi uisng umi-tools
###################
jobName="umi_dedup"
DIR_INPUT="${PWD}/BAMs"
DIR_OUT="${PWD}/BAMs_umi"
dir_logs=$PWD/logs

mkdir -p ${DIR_OUT}
mkdir -p ${dir_logs}

for file in $DIR_INPUT/*.bam;
do 
    FILENAME="$(basename $file)";
    fname=${FILENAME%.bam};
    fname=${fname/\#/\_}
    echo "$file" 
    echo $fname
    
    ## creat the script for each sample 
    script=${dir_logs}/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=6
#SBATCH --time=60
#SBATCH --mem=16G 

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.out 
#SBATCH -e ${dir_logs}/${fname}.err 
#SBATCH --job-name ${jobName}

#ml purge
#ml build-env/f2021
#ml python/3.8.6-gcccore-10.3.0
#ml pysam/0.16.0.1-gcc-10.2.0
#ml umi-tools/1.1.2-foss-2020b-python-3.8.6
#ml samtools/1.11-gcc-10.2.0
singularity exec --no-home --home /tmp /resources/containers/UMI_tools_v1.1.1.long_chr_pysam.simg umi_tools dedup \
--stdin=$file --log=${dir_logs}/${fname}_${jobName}.log --stdout ${DIR_OUT}/${fname}_umiDedup.bam

samtools sort -@ 6 -o ${DIR_OUT}/${fname}_umiDedup_sorted.bam ${DIR_OUT}/${fname}_umiDedup.bam

rm ${DIR_OUT}/${fname}_umiDedup.bam
mv ${DIR_OUT}/${fname}_umiDedup_sorted.bam ${DIR_OUT}/${fname}_umiDedup.bam
samtools index -c -m 14 ${DIR_OUT}/${fname}_umiDedup.bam

EOF
    
    cat $script;
    sbatch $script
    #break;
    
done
