#############################
# Count reads of RNA-seq data with HTSeq
# this gtf used here has only protein coding genes, which potentially keep more reads for quant-seq data
############################
while getopts ":hG:D:s:q:m:" opts; do
    case "$opts" in
        "h")
            echo "script to count reads for RNA-seq using htseq"
            echo "available genomes: WBcel235"
            echo "Usage: "
            echo "-h help"
	    echo "-G gtf file for gene annotation (default: protein coding and non-coding genes)"
            echo "-D directory of bam files (by default $PWD/BAMs)"
            echo "-s strand-specifity (no, yes, reverse)"
	    echo "-q threshold of read quality (default value 10)"
	    echo "-m counting mode in htseq"
            echo "Example:"
	    echo "$0 (all default parameters)"
            echo "$0 -s yes -q 10 -m intersection-nonempty"
            echo "$0 -D $PWD/BAMs_dedup -s yes -q 10 (absolute path)"

            exit 0
            ;;
        "D")
            DIR_input="$OPTARG"
            ;;
	"G")
	    GTF="$OPTARG"
	    ::
        "s")
            strandSpec="$OPTARG"
            ;;
	"q")
	    cutoff_quality="$OPTARG"
	    ;;
	"m")
	    mode="$OPTARG"
	    ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")

	    echo "No argument value for option $opts"
            ;;
        esac
done

jobName='htseq'
nb_cores=1
format=bam
DIR=`pwd`

if [ -z "$DIR_input" ]; then DIR_input="$PWD/BAMs"; fi; # bam directory

# GTF file
# protein-coding and non-coding (default)
if [ -z "$GTF" ]; then
    GTF="/groups/cochella/jiwang/annotations/Caenorhabditis_elegans.WBcel235.88.gtf"; 
fi;
# only protein coding genes
# GTF='/groups/cochella/jiwang/annotations/Caenorhabditis_elegans.WBcel235.88_proteinCodingGenes.gtf'# protein-coding and non-coding

if [ -z "$strandSpec" ]; then strandSpec=yes; fi # specificity
if [ -z "$cutoff_quality" ]; then cutoff_quality=10; fi; # cutoff of read quality
if [ -z "$mode" ]; then mode="intersection-nonempty"; fi;

ID_feature="gene_id"
DIR_output="${DIR}/htseq_counts_$(basename $DIR_input)"
dir_logs=$PWD/logs
echo "input folder -- " $DIR_input
echo "output folder -- "$DIR_output

mkdir -p $DIR_output;
mkdir -p $dir_logs

for file in ${DIR_input}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    #echo $fname
    file_output=${fname%.bam}.txt
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

# module load python/2.7.13-foss-2017a
# module load htseq/0.9.1-foss-2017a-python-2.7.13
source activate quantseq

htseq-count -f $format -s $strandSpec -a $cutoff_quality -t exon \
-i $ID_feature -m $mode $file $GTF \
> ${DIR_output}/$file_output

EOF

    cat $script;  
    sbatch $script    
    #break;

done
