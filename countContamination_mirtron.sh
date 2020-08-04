###################
# count the mirtron reads from the output of contamination for small RNA-seq data (initially)
###################
DIR_bams="$1"
OUT="contamination_countTable.txt"
ml load samtools/1.4-foss-2017a

echo sample mirtron35 mirtron51|tr ' ' '\t' > $OUT;

# loop over bam files
for bam in `ls ${DIR_bams}/*.bam`
do  
    bname=$(basename $bam);
    #keep=$bname;
    mirtron35=`samtools view $bam |grep Mirtron35|sort|wc -l`
    mirtron51=`samtools view $bam |grep Mirtron51|sort|wc -l`
    keep="$bname $mirtron35 $mirtron51"
    
    echo $keep|tr ' ' '\t' >> $OUT;
    echo $keep

done
