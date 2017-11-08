#####
## this script is to demultiplex the bam files from vbcf
####
GENOME="/groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/mm10_Refseq_index_4star"
nb_cores=8
file_urls="URLs_download.txt"

cwd=`pwd`
DIR_BAMs=$PWD/ngs_raw/BAMs
DIR_FASTQs=$PWD/ngs_raw/FASTQs
DIR_QC=$PWD/ngs_raw/FASTQC
DIR_alignment=$PWD/BAMs

mkdir -p $DIR_BAMs;
mkdir -p $DIR_FASTQs;
mkdir -p $DIR_QC;
mkdir -p $DIR_alignment;
mkdir -p $cwd/logs;
#cd ngs_raw
#mkdir -p RAWS

while read -r line; do
    #echo $line;
    IFS=$'\t' read -r "id" "type" "flowcell" "lane" "result" "countsQ30" "distinct" "preparation" "own_risk" "url" "md5" "comment" <<<  "$line"
    #echo $line;
    #echo $url
    #echo $own_risk
    #echo $md5
    #exit;
    ff=`basename $url`
    #echo $ff;
    
    if [ ! -e "${DIR_BAMs}/$ff" ] && [ $url=="http:*" ]; then
	#wget $url
	echo $url 
	#echo $url2
	#echo "$ff not downloaded yet ! "
	wget -c --no-check-certificate --auth-no-challenge --user 'Jingkui.Wang' --password '8A1P2EWa1K' $url -P $DIR_BAMs
    else
	echo "$ff already downloaded or Error in URL ! "
    fi
done < "$file_urls"
    
#exit;

for file in $DIR_BAMs/*.bam;
do 
   ff=`basename $file`
   #if [ -e "${DIR_BAMs}/$ff" ]; then
   out=${ff%.bam};
   echo $out
   qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star_mapping " module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}.fastq -o ${DIR_QC}; module load star/2.5.0a; STAR --runThreadN $nb_cores --genomeDir $GENOME --readFilesIn ${DIR_FASTQs}/${out}.fastq --outFileNamePrefix ${DIR_alignment}/$out --outSAMtype BAM SortedByCoordinate --outWigType wiggle --outWigNorm RPM; "
   #qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N star_mapping " module load bedtools; bamToFastq -i ${DIR_BAMs}/$ff -fq ${DIR_FASTQs}/${out}.fastq; module load fastqc; fastqc ${DIR_FASTQs}/${out}.fastq -o ${DIR_QC};"
       
    #fi;
done


