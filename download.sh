#!/bin/bash

#$ -q normal.q
#$ -N mock
#$ -M florentin.constancias@cirad.fr
#$ -pe parallel_smp 1
#$ -l mem_free=6G
#$ -V
#$ -cwd
#$ -V


module purge
module load system/conda/5.1.0 
source activate qiime1

# JOB BEGIN

##mock with Fwd Rev and indexes


for mock in mock-2
#mock-2 mock-3 mock-4 mock-5 mock-7 mock-8 mock-9
do

mkdir -p ${mock}

wget -c https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/data/${mock}/dataset-metadata.tsv \
	-O ${mock}/${mock}-dataset-metadata.tsv

wget -c https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/data/${mock}/README.md \
	-O ${mock}/${mock}-README.md

wget -c https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/data/${mock}/sample-metadata.tsv \
	-O ${mock}/${mock}-sample-metadata.tsv

sed -i -e 's/SampleID/#SampleID/g' ${mock}/${mock}-sample-metadata.tsv

wget -c https://s3-us-west-2.amazonaws.com/mockrobiota/latest/${mock}/mock-index-read.fastq.gz \
	-O ${mock}/${mock}-index-read.fastq.gz

wget -c https://s3-us-west-2.amazonaws.com/mockrobiota/latest/${mock}/mock-forward-read.fastq.gz \
	-O ${mock}/${mock}-forward-read.fastq.gz

wget -c https://s3-us-west-2.amazonaws.com/mockrobiota/latest/${mock}/mock-reverse-read.fastq.gz \
	-O ${mock}/${mock}-reverse-read.fastq.gz

for seqs in forward reverse
do
split_libraries_fastq.py \
    -i ${mock}/${mock}-${seqs}-read.fastq.gz \
    -o ${mock}/${mock}-split-libraries-${seqs} \
    -m ${mock}/${mock}-sample-metadata.tsv \
    -b ${mock}/${mock}-index-read.fastq.gz \
    --rev_comp_mapping_barcodes \
    --store_demultiplexed_fastq \
    -p 0.001 \
    -r 0 \
    -q 0 \
    -v 

split_sequence_file_on_sample_ids.py -i ${mock}/${mock}-split-libraries-${seqs} \
	--file_type fastq \
	-o ${mock}/${mock}-split-libraries-${seqs} \
	-v 

done
done

##mock with Fwd Rev already demultiplexed indexes

for mock in mock-12
#mock-12 mock-13 mock-14 mock-15 mock-16 mock-17 mock-18 mock-19 mock-20 mock-21 mock-22 mock-23 mock-24 mock-25

mkdir -p ${mock}

wget -c https://github.com/caporaso-lab/mockrobiota/tree/master/data/${mock}/dataset-metadata.tsv \
	-O ${mock}/${mock}-dataset-metadata.tsv

wget -c https://github.com/caporaso-lab/mockrobiota/tree/master/data/${mock}/README.md \
	-O ${mock}/${mock}-README.md

wget -c https://github.com/caporaso-lab/mockrobiota/tree/master/data/${mock}/sample-metadata.tsv \
	-O ${mock}/${mock}-sample-metadata.tsv 

wget -c https://s3-us-west-2.amazonaws.com/mockrobiota/latest/${mock}/mock-forward-read.fastq.gz \
	-O ${mock}/${mock}-forward-read.fastq.gz

wget -c https://s3-us-west-2.amazonaws.com/mockrobiota/latest/${mock}/mock-reverse-read.fastq.gz \
	-O ${mock}/${mock}-reverse-read.fastq.gz


done


# JOB END
date

exit 0
