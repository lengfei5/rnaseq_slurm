###################
## bam2fastq script
###################
DIR_INPUT="${PWD}/ngs_raw/FASTQs"
DIR_OUT="${PWD}/ngs_raw/FASTQs_umi"
dir_logs=$PWD/logs
#echo ${DIR_OUT};

mkdir -p ${DIR_OUT}

mkdir -p ${dir_logs}

for file in $DIR_INPUT/*.fastq;
do 
    FILENAME="$(basename $file)";
    fname=${FILENAME%.bam};
    fname=${fname/\#/\_}
    echo "$file" $fname
    
    ## creat the script for each sample 
    script=${dir_logs}/${fname}_umi_extract.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1 
#SBATCH --time=90 
#SBATCH --mem=10000 

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.out 
#SBATCH -e ${dir_logs}/${fname}.err 
#SBATCH --job-name umi_extract

source activate umitools
umi_tools extract --stdin=$file --bc-pattern=NNNNNN --log=${dir_logs}/${fname}_processed.log --stdout ${DIR_OUT}/${fname}_umi_extract.fastq

EOF
    
    cat $script;
    sbatch $script
    #break;
    
done