#####
## this script is to demultiplex the bam files from vbcf
####
GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
nb_cores=6

cwd=`pwd`
DIR_FASTQs=$PWD/ngs_raw/FASTQs_trimmed
DIR_alignment=$PWD/BAMs


mkdir -p $DIR_alignment;
mkdir -p $cwd/logs;

for file in ${DIR_FASTQs}/*.fastq;
do 
   ff=`basename $file`
   
   out=${ff%.fastq};
   echo $out
   
   qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star_mapping "module load star/2.5.0a; \
   STAR --runThreadN $nb_cores --genomeDir $GENOME --readFilesIn ${DIR_FASTQs}/${out}.fastq \
   --outFileNamePrefix ${DIR_alignment}/${out} --outSAMtype BAM SortedByCoordinate \
   --outWigType wiggle --outWigNorm RPM; "
      
   #break;
   
done


