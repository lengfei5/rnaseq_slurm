#########
## this script is to align RNA-seq data to WBcel235 c elegans genome using Star
#########
GENOME="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/index_4star"

align4YFP=FALSE;
nb_CORES=4;

mismatch_ratio=0.3; # max nb of mismatchi is mismatch_ratio * readLength (defaut 0.3)
mappedLength_ratio=0.66; # the ratio between mapped length and readd length (defaut 0.66)
max_IntronL=50000;
max_IntronL_YFP=100;

DIR_input_trimmed="$PWD/ngs_raw/FASTQs_trimmed"
DIR=`pwd`
OUT="${DIR}/BAMs"

echo $DIR_input_trimmed
echo $OUT
mkdir -p $OUT;
mkdir -p "$PWD/logs"

if [ "$align4YFP" = "TRUE" ]; then
    GENOME_YFP="/groups/bell/jiwang/Genomes/C_elegans/ce10/yfp_index_4star" 
    OUT_YFP="${DIR}/BAMs_YFP"
    echo $OUT_YFP
    mkdir -p $OUT_YFP
fi

for file in `ls ${DIR_input_trimmed}/*.fq ${DIR_input_trimmed}/*.fastq  2> /dev/null` ;
do
    echo $file
    #mv $file "${file%.fq}.fastq"
    #trimmed="${file%.fastq}_trimmed.fastq"
    #echo $trimmed
    bam=`basename $file`
    extension="${bam##*.}"
    #echo $bam
    bam="${bam%.$extension}.bam"
    echo $bam
    qsub -q public.q -o ${DIR}/logs -j yes -pe smp $nb_CORES -cwd -b y -shell y -N star_mapping "module load star/2.5.0a; STAR --runThreadN $nb_CORES --genomeDir $GENOME --readFilesIn $file --outFileNamePrefix ${OUT}/$bam --alignIntronMax $max_IntronL --outFilterMismatchNoverLmax $mismatch_ratio --outFilterMatchNminOverLread $mappedLength_ratio --outFilterType BySJout --outSAMtype BAM SortedByCoordinate --outWigType wiggle --outWigNorm RPM; " 
    if [ "$align4YFP" = "TRUE" ]; then
        qsub -q public.q -o ${DIR}/logs -j yes -pe smp $nb_CORES -cwd -b y -shell y -N star_mapping "module load star/2.5.0a; STAR --runThreadN $nb_CORES --genomeDir $GENOME_YFP --readFilesIn $file --outFileNamePrefix ${OUT_YFP}/$bam --alignIntronMax $max_IntronL_YFP --outFilterMismatchNoverLmax $mismatch_ratio --outFilterType BySJout --outSAMtype BAM SortedByCoordinate --outWigType wiggle --outWigNorm RPM; "
    fi
    #break;
done