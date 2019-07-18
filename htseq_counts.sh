#####
# count reads of RNA-seq data with HTSeq
#####
# this gtf has all annotation including non-coding regions and miRNAs
#GTF="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/Sequence_Annotation/Caenorhabditis_elegans.WBcel235.88.gtf"
# only protein coding genes
GTF='/groups/cochella/jiwang/annotations/Caenorhabditis_elegans.WBcel235.88_proteinCodingGenes.gtf'

nb_cores=1
jobName='htseq'
format=bam
strandSpec=yes;
cutoff_quality=10
mode="intersection-nonempty"
ID_feature="gene_id"

DIR=`pwd`
DIR_input="${DIR}/BAMs"
DIR_output="${DIR}/htseq_counts"
dir_logs=$PWD/logs
echo $DIR_input
echo $DIR_output

mkdir -p $DIR_output;
mkdir -p $dir_logs

for file in ${DIR_input}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    #echo $fname
    file_output=${fname%.bam}
    #echo $file_output

    script=${dir_logs}/$(basename $file)_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=120
#SBATCH --mem=6000
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/$(basename $file).out
#SBATCH -e ${dir_logs}/$(basename $file).err
#SBATCH --job-name $jobName

module load htseq/0.9.1-foss-2017a-python-2.7.13

htseq-count -f $format -s $strandSpec -a $cutoff_quality -t exon \
-i $ID_feature -m $mode -f bam $file $GTF \
> ${DIR_output}/$file_output

htseq-count -f $format -s $strandSpec -a $cutoff_quality -t exon \
-i $ID_feature -m $mode -f bam $file $GTF \
> ${DIR_output}/$file_output


EOF

    cat $script;  
    sbatch $script
    #break;
done
