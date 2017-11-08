#####
# this script is to aligne fastq file with indexed genome
# now only for mm10 and ce genome will be added
####
# genome
GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
nb_cores=8

cwd=`pwd`

# output directories
DIR_FASTQs=$PWD/ngs_raw/FASTQs
DIR_QC=$PWD/ngs_raw/FASTQC
DIR_alignment=$PWD/BAMs
mkdir -p $DIR_FASTQs;
mkdir -p $DIR_QC;
mkdir -p $DIR_alignment;
mkdir -p $cwd/logs;

# loop over fastq or fq files
for file in `ls $DIR_FASTQs/*.fastq $DIR_FASTQs/*.fq`;
do 
   ff=`basename $file`
   
   #if [ -e "${DIR_BAMs}/$ff" ]; then
   #out="${filename%.*}"
   out="${ff%.*}";
   echo "alignment for $ff";
   qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star.map "module load fastqc; fastqc ${ff} -o ${DIR_QC}; module load star/2.5.0a; STAR --runThreadN $nb_cores --genomeDir $GENOME --readFilesIn ${DIR_FASTQs}/${out}.fastq --outFileNamePrefix ${DIR_alignment}/$out --outSAMtype BAM SortedByCoordinate --outWigType wiggle --outWigNorm RPM; "
   
done


