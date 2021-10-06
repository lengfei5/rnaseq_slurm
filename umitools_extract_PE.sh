###################
# umi extract with umi_tools extract for PE
# there is an issue for PE https://github.com/CGATOxford/UMI-tools/issues/391
# if umi is in the R2, R2 should be go first
# new version of umi-tools should fix this, but cbe currently does not have it
###################
DIR_INPUT="${PWD}/ngs_raw/FASTQs"
DIR_OUT="${PWD}/ngs_raw/FASTQs_umi"
dir_logs=$PWD/logs
#echo ${DIR_OUT};

mkdir -p ${DIR_OUT}

mkdir -p ${dir_logs}

for seq1 in `ls ${DIR_INPUT}/*.fastq | grep "_R1"`;
do
    fname="$(basename $seq1)"
    SUFFIX=${fname#*_R1}
    fname=${fname%_R1*}
    
    seq2=${DIR_INPUT}/${fname}_R2${SUFFIX};
    echo $fname
    echo $seq1
    echo $seq2
    
    ## creat the script for each sample 
    script=${dir_logs}/${fname}_umi_extract.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1 
#SBATCH --time=180 
#SBATCH --mem=10000 

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.out 
#SBATCH -e ${dir_logs}/${fname}.err 
#SBATCH --job-name umi_extract

ml load umi-tools/1.0.0-foss-2018b-python-3.6.6
umi_tools extract -I $seq2 -S ${DIR_OUT}/${fname}_umiExtracted_R2.fastq --extract-method regex \
--bc-pattern='(?P<umi_1>.{12})(?P<discard_1>TTTTT)' --read2-in=$seq1 --read2-out=${DIR_OUT}/${fname}_umiExtracted_R1.fastq

EOF
    
    cat $script;
    sbatch $script
    #break;
    
done
