#GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
#GTF="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/Sequence/mm10_refGene.gtf"
GTF="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/Sequence_Annotation/Caenorhabditis_elegans.WBcel235.88.gtf"
CORES=1

format=bam
strandSpec="no";
cutoff_quality=10
mode="intersection-nonempty"
ID_feature="gene_id"

DIR=`pwd`
DIR_input="${DIR}/BAMs"
DIR_output="${DIR}/readCounts_htseq"
echo $DIR_input
echo $DIR_output
mkdir -p $DIR_output;
mkdir -p $PWD/logs

for file in ${DIR_input}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    #echo $fname
    file_output=${fname%.bam}.txt
    #echo $file_output
    qsub -q public.q -o ${PWD}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N HTseq_counts "module load htseq-count/0.6.1; htseq-count -f $format -s $strandSpec -a $cutoff_quality -t exon -i $ID_feature -m $mode -f bam $file $GTF > ${DIR_output}/$file_output; module load samtools; samtools index $file "
    #break;
done