# RNA-seq pipeline for bulk RNA seq data and quant-seq data
(now it is being updated for slurm and make it in nextflow one day)
RNAseq is a pipeline to process RNA-seq data from raw data to the table for read counts 
     In addition, scripts dealing with standard RNA-seq, Quant-seq and small RNA-seq are all included, in this folder fo   r the moments, due to its complexicity and specificity of single-cell RNA-seq analysis, another folder scRNAseq were specially made for it (../scRNAseq/).
 while shared processing step and alignment are still found in this folder
######################################################


#####################################################
Details for functions 
######################################################
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

- why there is no color in emacs ???