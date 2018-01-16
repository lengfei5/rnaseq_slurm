#GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
#GENOME="/groups/bell/jiwang/Genomes/C_elegans/ce10/ce10_index_4star"
CORES=6
DIR=`pwd`
mkdir -p "${DIR}/logs"

DIR_input="${DIR}/ngs_raw/FASTQs"
DIR_trimmed="${DIR}/ngs_raw/FASTQs_trimmed"
DIR_output="${DIR}/BAMs"
echo $DIR_input
echo $DIR_output
echo $DIR_trimmed
mkdir -p $DIR_output
mkdir -p $DIR_trimmed

#mkdir -p ${DIR_output}/logs

for file in ${DIR_input}/*.fastq;
do
    echo $file
    trimmed="${file%.fastq}_trimmed.fastq"
    echo $trimmed
    qsub -q public.q -o ${DIR}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N trimming "module load fastqc/0.11.5; module load trimgalore/0.3.7;\
trim_galore $file --phred33 --fastqc --fastqc_args "--outdir $DIR_trimmed" --adapter AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG --stringency 3 --dont_gzip --length 20 -o $DIR_trimmed --clip_R1 12;" 

done