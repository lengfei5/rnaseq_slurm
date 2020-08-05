###################
# count the mirtron reads from the output of contamination for small RNA-seq data (initially)
###################
DIR_bams="$1"
OUT="contamination_countTable.txt"
ml load samtools/1.4-foss-2018b


mirtron35='TCACCGGGTGTAAACTTACAG'
mirtron51='TACCCGTAATCTTCATAATTACAG'

echo sample mirtron35_read mirtron35_umi mirtron51_read mirtron51_umi|tr ' ' '\t' > $OUT;

# loop over bam files
for bam in `ls ${DIR_bams}/*.bam`
do  
    bname=$(basename $bam);
    keep="$bname"
    # select reads fully mapped to mirtron 35 and count the read and umi 
    #mirtron35_read=`samtools view $bam |grep "TCACCGGGTGTAAACTTACAG"|sort|wc -l`
    mirtron35_read_20=`samtools view $bam | awk '$10 == "TCACCGGGTGTAAACTTACAG"' | wc -l`
    mirtron35_umi=`samtools view $bam | awk '$10 == "TCACCGGGTGTAAACTTACAG"' | cut -f1|tr '_' '\t'|cut -f2|sort -u|wc -l`
    # select reads fully mapped to mirtron 35 and count the read and umi
    mirtron51_read=`samtools view $bam | awk '$10 == "TACCCGTAATCTTCATAATTACAG"' | wc -l`
    mirtron51_umi=`samtools view $bam | awk '$10 == "TACCCGTAATCTTCATAATTACAG"' | cut -f1|tr '_' '\t'|cut -f2|sort -u|wc -l`
    #mirtron51=`samtools view $bam |grep Mirtron51|sort|wc -l`
    
    keep="$bname $mirtron35_read $mirtron35_umi $mirtron51_read $mirtron51_umi"

    echo $keep
    echo $keep|tr ' ' '\t' >> $OUT;
   
    break
    
done
