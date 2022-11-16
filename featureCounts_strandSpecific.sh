while getopts ":hD:a:" opts; do
    case "$opts" in
        "h")
            echo "script to quantify read count from aligned bam files)"
            echo "Two arguments required"
            echo "-D the directory of bam files "
            echo "-a gtf file or annotation file "
            echo "Usage:"
            echo "$0 -D alignments/BAMs_All -a "
            exit 0
            ;;
        "D")
            DIR_input="$OPTARG";
            ;;
        "a")
            gtf="$OPTARG";
            ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option $opts"
            ;;
        esac
done

nb_cores=4
jobName='featurecounts'
format=bam
strandSpec=1;

cutoff_quality=30

DIR_output="${PWD}/featurecounts_Q${cutoff_quality}"
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
#SBATCH --time=480
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/$(basename $file).featureCounts.out
#SBATCH -e ${dir_logs}/$(basename $file).featureCounts.err
#SBATCH --job-name $jobName

ml load subread/2.0.1-gcc-7.3.0-2.30

featureCounts -t exon -a $gtf -Q $cutoff_quality \
-g gene_id -T $nb_cores \
-o ${DIR_output}/${file_output}_featureCounts.txt \
-s $strandSpec $file;

EOF

    cat $script;  
    sbatch $script
    #break;
    
done
