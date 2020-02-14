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

#SBATCH --cpus-per-task=1 
#SBATCH --time=90 
#SBATCH --mem=10000 

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.out 
#SBATCH -e ${dir_logs}/${fname}.err 
#SBATCH --job-name ${jobName}

source activate umitools
umi_tools dedup --stdin=$file --log=${dir_logs}/${fname}_${jobName}.log --stdout ${DIR_OUT}/${fname}_umiDedup.bam

EOF
    
    cat $script;
    sbatch $script
    #break;
    
done
