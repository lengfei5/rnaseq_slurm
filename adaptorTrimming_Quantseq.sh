#GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
#GENOME="/groups/bell/jiwang/Genomes/C_elegans/ce10/ce10_index_4star"
CORES=2
DIR=`pwd`
USE_cutadapt="TRUE";
mkdir -p "${DIR}/logs"

DIR_input="${DIR}/ngs_raw/FASTQs"
DIR_trimmed="${DIR}/ngs_raw/FASTQs_trimmed"
DIR_fastqc="${DIR}/ngs_raw/FASTQCs/"
#DIR_output="${DIR}/BAMs"
#echo $DIR_input
#echo $DIR_trimmed

#echo $DIR_output
#mkdir -p $DIR_output
mkdir -p $DIR_trimmed
mkdir -p $DIR_fastqc


#mkdir -p ${DIR_output}/logs
adaptor_seq="AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG"
#polyA="$(echo -e ''$_{1..100}'\bA')"
#echo $adaptor_seq
#echo $polyA

for file in ${DIR_input}/*.fastq;
do
    echo $file
    trimmed="${file%.fastq}_trimmed.fastq"
    #echo $trimmed
    if [ "${USE_cutadapt}" == "TRUE" ]; then
	cd $DIR_input;
	out=`basename $trimmed`;
	#out=${DIR_trimmed}/${out}
	echo $out
	qsub -q public.q -o ${DIR}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N trimming "module load fastqc/0.11.5; \
         module load python; module load cutadapt/1.12.0;  \
         cutadapt -a A{100} -a $adaptor_seq -n 2 -m 30 -f fastq -o ${out} $file > ${DIR_trimmed}/${out}.cutadapt.log; \
         mv ${out} $DIR_trimmed; fastqc ${DIR_trimmed}/${out} -o ${DIR_fastqc}"
        
	cd $DIR;

    else
	echo qsub -q public.q -o ${DIR}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N trimming "module load fastqc/0.11.5; \
         module load trimgalore/0.3.7;\
         trim_galore $file --phred33 --fastqc --fastqc_args \"--nogroup --outdir ${DIR_fastqc}\" \
         --adapter $adaptor_seq --stringency 3 --dont_gzip --length 20 -o $DIR_trimmed --clip_R1 12;" 
    fi
    #break;
done