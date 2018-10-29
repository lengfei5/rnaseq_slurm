mkdir -p $PWD/logs 
nb_cores=6;
qsub -q public.q -o ${PWD}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N repeat_index "python RepEnrich2_setup.py data/mm10_repeatmasker.txt /groups/bell/jiwang/Genomes/Mouse/mm10_UCSC/Sequence/genome.fa data/repeat_mm10; "