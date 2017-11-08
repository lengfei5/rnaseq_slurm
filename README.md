## RNAseq is a pipeline to process RNA-seq data from raw data to the table for read counts 

Documentation for the list of functions
download_alignment.sh
  This function is to 
    download demultipled bam files (without alignment) from links provided by VBVF, 
    convert bam file to fastq
    check sequencing quality using fastqc
    align fastq file to genome (indexed before, here is the mouse genome (mm10) indexed using RefSeq 
    gene annotation. 
    
  Input is text file with URL; particular cares should be taken for format of this text file
  Improvement need to be done to make it more flexible
