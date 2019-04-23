#############
# This script is to merge bam files
# requiring arguments:
# input (directory for bams files),
# output directory (optional if different from the directory of initial bams),
# a text file that specifies according what to merge 
# (same sample ID or replicates, i.e., same condition) and file names after merging. 
# updated for slurm
############
while getopts ":hD:O:f:" opts; do
    case "$opts" in
        "h")
            echo "This script is to merge bam files requiring arguments: "
	    echo "-D (input directory for bams files) "
            echo "-O (output directory optional if different from the directory of initial bams) "
            echo "-f (barcode file in text two columns, sampleID and barcode)"
            echo "Usage:"
            echo "$0 -D ngs_raw/sRBCs -O ngs_raw/demultiplexed -f barcode.txt"
            exit 0
            ;;
        "D")
            DIR_Bams="$OPTARG"
            ;;
	"O")
	    OUT="$OPTARG";
	    ;;
	"f")
	    bc_file="$OPTARG";
	    ;;
	"?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option -DOf "
	    exit 1;
            ;;
    esac
done

if [ -z "$OUT" ]; then 
    OUT=$DIR_Bams;
fi

if [ ! -f "$bc_file"  ]; then
    echo "-- Error: barcode file missing --"
    exit 1;
fi

# internal params
nb_cores=2
jobName='demultiplex'

adapter="AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG"

cwd=$PWD;
dir_logs=${cwd}/logs
mkdir -p $DIR_OUT
mkdir -p $dir_logs

for bam in ${DIR_Bams}/*.bam; do
    echo $bam
    name=`basename $bam`
    name=${name%%.bam}
    echo $name
    script=${dir_logs}/${name}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=360
#SBATCH --mem=2000
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${script}.out
#SBATCH -e ${script}.err
#SBATCH --job-name $jobName

ml load bedtools/2.25.0-foss-2017a;
ml load samtools/1.9-foss-2017a
ml load fastx-toolkit/0.0.14-foss-2017a
ml load cutadapt/1.9.1-foss-2017a-python-2.7.13

samtools view -c ${bam} > ${OUT}/${name}_cntTotal.txt
bamToFastq -i ${bam} -fq /dev/stdout | \
cutadapt -e 0.1 -a ${adapter} -f fastq -o ${OUT}/${name}_cutadapt.fastq - > ${OUT}/${name}_cutadapt.err
cat ${OUT}/${name}_cutadapt.fastq | fastx_barcode_splitter.pl --bcfile $bc_file --eol --exact --prefix ${OUT}/${name}_ --suffix .fastq


EOF
    
    cat $script;
    sbatch $script
        
    break;
done


