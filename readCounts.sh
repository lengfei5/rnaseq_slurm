#######
## this script is to quantify read count table using GTF annotation and HTseq
#######
#GTF="/groups/bell/jiwang/annotations/mm10/Refseq/mm10_RefSeq_curated.gtf"
GTF="/groups/bell/jiwang/annotations/mm10/Refseq/mm10_refGene.rRNA.gtf"

CORES=2
cwd=`pwd`
DIR_Bam="$PWD/BAMs"
OUT="$PWD/readcounts_htseq"

### parameters for htseq-count
strand=reverse;
mode=union;
minqual=10;
format=bam

#mkdir -p ${DIR}/read_counts
echo $DIR_Bam
echo $OUT

mkdir -p ${OUT}
mkdir -p ${cwd}/logs

#mkdir -p ${DIR_output}/logs
for file in ${DIR_Bam}/*.bam;
do
    #echo $file
    fname="$(basename $file)"
    #echo $fname
    file_output=${fname%.bam}.txt
    echo $file_output
    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N HTseq_counts "module load htseq-count/0.6.1; htseq-count -s $strand -a $minqual -t exon -m $mode -f $format $file $GTF > ${OUT}/$file_output"
    #qsub -q public.q -o ${DIR_output}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N mapping2genome "module load samtools/0.1.18;module load bowtie2/2.2.4;bowtie2 -q -p $nb_cores -x $Genome -U $file | samtools view -bSu - | samtools sort - ${DIR_output}/$fname"
    #break;
done