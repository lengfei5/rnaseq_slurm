###################
# count the spkie-ins sequences for small RNA-seq data (initially)
###################
spike_seq="/groups/cochella/jiwang/scripts/smallRNA_nf/genome/spikeIn.fa";
DIR_bams="$PWD/ngs_raw"
OUT="spikeIns_count_table.txt"

echo sample spikeIn_{1..8}|tr ' ' '\t' >> $OUT;

# loop over bam files
for bam in `ls ${DIR_bams}/*.bam`
do  
    bname=$(basename $bam);
    #echo $bname >> $OUT;
    keep=$bname;
    # loop over spike-in sequences
    for seq in `cat $spike_seq |grep -v ">"`
    do 
	echo $bam "--" $seq;
	count=`samtools view $bam |cut -f10|cut -c9-21|grep -c $seq`
	#count=0
	keep="$keep $count"
    done 
    echo $keep|tr ' ' '\t' >> $OUT;
done
