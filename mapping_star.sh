#########
# this script is to align RNA-seq data using Star
#########
while getopts ":hg:D:c:" opts; do
    case "$opts" in
        "h")
            echo "script to map RNAseq fastq or fq using Star"
            echo "available genomes: ce11 and mm10"
            echo "Usage: "
	    echo "-h help"
	    echo "-g genome (ce11, mm10, hg38)"
	    echo "-D directory of fastq file; by default ngs_raw/FASTQs"
	    echo "-c nb of cores to use in cluster ; 6 is by default"
	    echo "Example:"
            echo "$0 -g ce11 -c 4 "
            echo "$0 -g mm10 -c 8 (single_end fastq aligned to mm10 and 8 cpus required)"
            
            exit 0
            ;;
        "g")
            genome="$OPTARG"
	    #echo $genome;
            ;;
	"D") 
	    DIR_input="$OPTARG"
	    ;;
        "c")
            nb_cores="$OPTARG"
            ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option $opts"
            ;;
        esac
done

# select genome and parameters accordingly
case "$genome" in
    "ce11")
 echo "alignment to WBcel235 "
        GENOME="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/index_4star"
 
	mismatch_ratio=0.3; # max nb of mismatchi is mismatch_ratio * readLength (defaut 0.3)
	mappedLength_ratio=0.66; # the ratio between mapped length and readd length (defaut 0.66)
	max_IntronL=50000;
	#max_IntronL_YFP=100;
	;;
    
    "mm10")
        echo "alignment to mm10 RefSeq"
        GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
        ;;

    "hg38")
        echo "alignment to hg38 UCSC"
        GENOME='/groups/cochella/jiwang/Genomes/Human/hg38/sequence/index_4star'
        ;;
  
    *)
        echo " No indexed GENOME Found !! "
        echo "Usage: $0 -g mm10 "
        exit 1;
        ;;
esac

# nb of cpus
if [ -z "$nb_cores"]; then
    nb_cores=8;
fi

# fastq directory
if [ -z "$DIR_input" ]; then
    DIR_input="$PWD/ngs_raw/FASTQs"
fi

cwd=`pwd`
OUT="${cwd}/BAMs"
dir_logs=$PWD/logs

echo "fastq folder -- $DIR_input"
echo "output bam folder -- $OUT"
echo "nb of cpus -- $nb_cores "
mkdir -p $OUT;
mkdir -p $dir_logs
jobName='star'


for file in `ls ${DIR_input}/*.fq ${DIR_input}/*.fastq  2> /dev/null` ;
do
    echo "fastq file -- $file"
    bam=`basename $file`
    extension="${bam##*.}"
    #echo $bam
    out="${bam%.$extension}"
    bam="${bam%.$extension}"
    echo "bam file -- $bam"
    
    # creat the script for each sample
    script=$dir_logs/${bam}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=120
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $dir_logs/${bam}.star.out
#SBATCH -e $dir_logs/${bam}.star.err
#SBATCH --job-name $jobName

module load star/2.5.2a-foss-2018b
module load samtools/1.9-foss-2018b
EOF
    
    if [ "$genome" == "ce11" ]; then
	    cat <<EOF >> $script
STAR --runThreadN $nb_cores --genomeDir $GENOME --readFilesIn $file \
--outFileNamePrefix ${OUT}/$bam \
--alignIntronMax $max_IntronL \
--outFilterMismatchNoverLmax $mismatch_ratio \
--outFilterMatchNminOverLread $mappedLength_ratio \
--outFilterType BySJout \
--outSAMtype BAM Unsorted

samtools sort -o ${OUT}/${bam}_sorted.bam ${OUT}/${bam}Aligned.out.bam
samtools index ${OUT}/${bam}_sorted.bam
rm ${OUT}/${bam}Aligned.out.bam

EOF
    else
	cat <<EOF >> $script
STAR --runThreadN $nb_cores --genomeDir $GENOME --readFilesIn $file \
--outFileNamePrefix ${OUT}/${out} \
--outSAMtype BAM Unsorted

samtools sort -o ${OUT}/${bam}_sorted.bam ${OUT}/${bam}Aligned.out.bam
samtools index ${OUT}/${bam}_sorted.bam
rm ${OUT}/${bam}Aligned.out.bam

EOF
	
    fi
    
   cat $script;
   sbatch $script 
   #break;

done
