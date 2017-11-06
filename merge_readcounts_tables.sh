### this script is to merge read count into one table
CountsFiles="$@";
#DIR="$1"
finalTable="final_merged_Table.txt"

tmp="tmp.txt"
if [[ -f $PWD/$finalTable ]]; then rm $finalTable; fi
if [[ -f $PWD/$tmp ]]; then rm $tmp; fi

i=1
fields[0]="RefseqID";
for sample_id in $CountsFiles; do
    echo $sample_id
    
    if [[ $i -eq 1 ]]; then
	echo $i
	cp $sample_id $finalTable
	fields[$[$i]]=`basename $sample_id`;
	#echo $sample_id;
	#file1=$(ls *.txt | grep 47414)
	#file2=$(ls *.txt | grep $sample_id)
	#echo $file1
	#echo $file2
	#join $file1 $file2 > $finalTable
	#cp $sample_id temp.txt
	
    else
	#echo "not the first "
	#echo $sample_id
	#echo $file2
	#file2=$(ls *.txt | grep $sample_id)
	fields[$[$i]]=`basename $sample_id`;
	join -j1 $finalTable $sample_id > $tmp
	cp $tmp $finalTable
	rm $tmp
    fi 
    #echo $i;
    i=$((i+1));
    #echo $i;
done

#echo ${fields[*]// /\t} > header.txt
echo ${fields[*]} > header.txt
cat header.txt $finalTable > $tmp
cp $tmp $finalTable   
rm tmp.txt