#####################################
# script to trim adaptors for fastq files and run fastqc after trimming
# two modules possible: cutadapt which need the adaptor sequences to be speficied
# but the adavantage of using cutadapt isthat it can trim polyA at the same time (however this polyA trimming is not
# implemented for some reasons)
# trimglore which does not need the adaptor sequences and this option is removed now
#
# add polyA trimming in cutadapt
#####################################

minLength_overlap=3; # default 3 
times_trimming=1;# default 1 
minimumLength=20; # default 0


DIR=`pwd`
DIR_input="${DIR}/ngs_raw/FASTQs"
DIR_trimmed="${DIR}/ngs_raw/FASTQs_trimmed"
DIR_fastqc="${DIR}/ngs_raw/FASTQCs_trimmed/"

mkdir -p $DIR_trimmed
mkdir -p "${DIR}/logs"

jobName='trimming'

for file in ${DIR_input}/*.fastq;
do
    echo $file
    fname=`basename ${file%.fastq}`
    trimmed="${file%.fastq}_trimmed.fastq"
    echo $fname $trimmed
    
    cd $DIR_input;
    out=`basename $trimmed`;
    echo $out
    
    # creat the script for each sample
    script=$PWD/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=480
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR/logs/$fname.out
#SBATCH -e $DIR/logs/$fname.err
#SBATCH --job-name $jobName

ml load cutadapt/1.18-foss-2018b-python-3.6.6
ml load picard/2.20.6--0-biocontainers
cutadapt -l 50 -f fastq -o ${out} $file > ${DIR_trimmed}/${out}.cutadapt.log;
picard FastqToSam F1=${out} O=${out}.bam SM=sample001 RG=rg0013

mv ${out} $DIR_trimmed
mv ${out}.bam $DIR_trimmed

EOF

    cat $script;
    sbatch $script
    cd $DIR;
    
    #break;
    
done
