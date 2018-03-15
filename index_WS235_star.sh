nb_cores=10;
Genome="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/Sequence_Annotation/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa"
GFF="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/Sequence_Annotation/Caenorhabditis_elegans.WBcel235.88.gtf"
OUT="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/index_4star"

qsub -q public.q -o output.log -j yes -pe smp $nb_cores -cwd -b y -shell y -N index4star "module load star/2.5.0a; STAR --runMode genomeGenerate --runThreadN $nb_cores --genomeDir $OUT --genomeFastaFiles $Genome --sjdbGTFfile $GFF"
