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
#SBATCH --time=180 
#SBATCH --mem=16G 

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.out 
#SBATCH -e ${dir_logs}/${fname}.err 
#SBATCH --job-name umi_extract

ml purge
ml build-env/f2021
ml umi-tools/1.1.2-foss-2020b-python-3.8.6

umi_tools extract \
--extract-method=regex \
--bc-pattern='^(?P<discard_1>ATTGCGCAATG)(?P<umi_1>.{8})(?P<discard_2>.{4}).*' \
--stdin=$file \
--log=${dir_logs}/${fname}_processed.log \
--stdout ${DIR_OUT}/${fname}_umi.fastq \
--filtered-out ${DIR_OUT}/${fname}_nonumi.fastq 

EOF
    
    cat $script;
    sbatch $script
    #break;
    
done
