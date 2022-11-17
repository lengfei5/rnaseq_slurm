#####################################
# script to trim adaptors for fastq files and run fastqc after trimming
# two modules possible: cutadapt which need the adaptor sequences to be speficied
# but the adavantage of using cutadapt isthat it can trim polyA at the same time (however this polyA trimming is not
# implemented for some reasons)
# trimglore which does not need the adaptor sequences and this option is removed now
#
# add polyA trimming in cutadapt
#####################################
DIR=`pwd`
DIR_input="${DIR}/ngs_raw/FASTQs"
DIR_trimmed="${DIR}/ngs_raw/FASTQs_trimmed"

mkdir -p $DIR_trimmed
mkdir -p "${DIR}/logs"

jobName='trimming'

for seq1 in `ls ${DIR_input}/*.fastq | grep "_R1"`;
do
    fname="$(basename $seq1)"
    SUFFIX=${fname#*_R1}
    fname=${fname%_R1*}
    
    seq2=${DIR_input}/${fname}_R2${SUFFIX};
    
    echo $fname
    echo $seq1
    echo $seq2
    
    #cd $DIR_input;
    #out=`basename $trimmed`;
    #echo $out
    
    # creat the script for each sample
    script=${DIR}/logs/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=120
#SBATCH --mem=8G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR/logs/$fname.out
#SBATCH -e $DIR/logs/$fname.err
#SBATCH --job-name $jobName

module load cutadapt/1.18-foss-2018b-python-3.6.6

cutadapt -f fastq --cores=1 --pair-filter=any --overlap=3 --minimum-length=20 --times=1 \
-a CTGTCTCTTATA -A AGATCGGAAGAGC \
-o ${DIR_trimmed}/${fname}_adapTrimmed_R1.fastq \
-p ${DIR_trimmed}/${fname}_adapTrimmed_R2.fastq \
$seq1 $seq2 > ${DIR_trimmed}/${fname}_cutadapt1.txt

cutadapt -f fastq --cores=1 --pair-filter=any --overlap=3 --minimum-length=20 --times=1 \
-a "A{100}" -A "A{100}" \
-o ${DIR_trimmed}/${fname}_adapPolyA.trimmed_R1.fastq \
-p ${DIR_trimmed}/${fname}_adapPolyA.trimmed_R2.fastq \
${DIR_trimmed}/${fname}_adapTrimmed_R1.fastq ${DIR_trimmed}/${fname}_adapTrimmed_R2.fastq \
> ${DIR_trimmed}/${fname}_cutadapt2.txt

EOF

    cat $script;
    sbatch $script
    
    #break;
    
done
