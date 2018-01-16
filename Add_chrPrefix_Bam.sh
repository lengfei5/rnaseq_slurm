bam=$1;
samtools view -h $bam |sed -e '/^@SQ/s/SN\:/SN\:chr/' -e '/^[^@]/s/\t/\tchr/2'| awk -F ' ' '$7=($7=="=" || $7=="*"?$7:sprintf("chr%s",$7))' |tr " " "\t"
