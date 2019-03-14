#####################################
# script to trim adaptors for fastq files and run fastqc after trimming
# two modules possible: cutadapt which need the adaptor sequences to be speficied
# but the adavantage of using cutadapt isthat it can trim polyA at the same time;
# trimglore which does not need the adaptor sequences and this option is removed now
#  
#####################################
USE_cutadapt="TRUE";
use_adatpSeq="TRUE"
trim_polyA="TRUE";

if [ "$USE_cutadapt" == "TRUE" ]; then
    #adaptor_seq="AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG" # quant-seq adaptor
    adaptor_seq="CTGTCTCTTATACACATCTCCGAGCCCACGAGAC"; # Nextera adatptor
    minLength_overlap=3;
    times_trimming=1;
    minimumLength=20;
fi

CORES=1
DIR=`pwd`

DIR_input="${DIR}/ngs_raw/FASTQs"
DIR_trimmed="${DIR}/ngs_raw/FASTQs_trimmed"
DIR_fastqc="${DIR}/ngs_raw/FASTQCs/"
#echo $DIR_input
#echo $DIR_trimmed
#echo $DIR_output

mkdir -p $DIR_trimmed
mkdir -p $DIR_fastqc
mkdir -p "${DIR}/logs"


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
         cutadapt -a $adaptor_seq -n $times_trimming -O $minLength_overlap -m $minimumLength -f fastq -o ${out} $file > ${DIR_trimmed}/${out}.cutadapt.log; \
         mv ${out} $DIR_trimmed; fastqc ${DIR_trimmed}/${out} -o ${DIR_fastqc}"
        
	cd $DIR;

    else
	qsub -q public.q -o ${DIR}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N trimming " \
        module load fastqc/0.11.5; \
        cutadapt/1.12.0;\
        /home/imp/jingkui.wang/local/bin/trim_galore $file --phred33 \
        --fastqc --fastqc_args \"--nogroup --outdir ${DIR_fastqc}\" \
        --nextera --stringency 1 --dont_gzip --length 10 -o $DIR_trimmed;" 
    fi
    #break;
done
