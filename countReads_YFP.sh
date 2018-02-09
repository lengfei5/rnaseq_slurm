#GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
#GTF="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/Sequence/mm10_refGene.gtf"
#GTF="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/Sequence_Annotation/Caenorhabditis_elegans.WBcel235.88.gtf"
CORES=4
cutoff_quality=30

mode="intersection-nonempty"
ID_feature="gene_id"

DIR=`pwd`
DIR_input="${DIR}/BAMs_YFP"
#DIR_output="${DIR}/read_counts_YFP"
echo $DIR_input
#echo $DIR_output
#mkdir -p $DIR_output;
mkdir -p $PWD/logs
mkdir -p $PWD/Olds

YFP1="YFP_readCounts_yfpseq_coordinate_30_900.txt"
YFP2="YFP_readCounts_yfpseq_coordinate_30_1350.txt"
YFP3="YFP_readCounts_yfpseq_coordinate_900_1350.txt"
module load samtools;
#header=
#counts=
i=0; 
#mkdir -p ${DIR_output}/logs
for file in ${DIR_input}/*.bam;
do
    echo $file
    if [ ! -e ${file}.bai ]; then
	samtools index $file
    fi
    #samtools view -F 16 $file
    fname="$(basename $file)"
    header[$[$i]]="$fname";
    
    #echo $fname
    #file_output=${fname%.bam}.txt
    #echo $file_output
    #echo $counts
    #samtools view -F 16 $file | wc
    samtools view -q $cutoff_quality -b $file > align_q1.bam
    samtools sort align_q1.bam align_q1_sorted
    samtools index align_q1_sorted.bam 
    
    counts1[$[i]]=`samtools view -F 16 align_q1_sorted.bam chrYFP:30-900 | cut -f1 | sort | uniq | wc -l `
    counts2[$[i]]=`samtools view -F 16 align_q1_sorted.bam chrYFP:30-1200 | cut -f1 | sort | uniq | wc -l `
    counts3[$[i]]=`samtools view -F 16 align_q1_sorted.bam chrYFP:900-1200 | cut -f1 | sort | uniq | wc -l `
    let "i+=1"
    #qsub -q public.q -o ${PWD}/logs -j yes -pe smp $CORES -cwd -b y -shell y -N HTseq_counts "module load htseq-count/0.6.1; htseq-count -s yes -a $cutoff_quality -t exon -i $ID_feature -m $mode -f bam $file $GTF > ${DIR_output}/$file_output; module load samtools; samtools index $file "
    mv align_q1* Olds
    #break;
done

echo ${header[*]}|tr ' ' '\t' > $YFP1
echo ${counts1[*]}|tr ' ' '\t' >> $YFP1
echo ${header[*]}|tr ' ' '\t' > $YFP2
echo ${counts2[*]}|tr ' ' '\t' >> $YFP2
echo ${header[*]}|tr ' ' '\t' > $YFP3
echo ${counts3[*]}|tr ' ' '\t' >> $YFP3
